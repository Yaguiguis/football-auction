alter table public.fa_rooms
  add column if not exists room_kind text not null default 'auction',
  add column if not exists tournament_size integer null,
  add column if not exists tournament_champion_member_id uuid null;

do $$
begin
  if not exists (select 1 from pg_constraint where conname='fa_rooms_room_kind_check') then
    alter table public.fa_rooms add constraint fa_rooms_room_kind_check check (room_kind in ('auction','tournament'));
  end if;
  if not exists (select 1 from pg_constraint where conname='fa_rooms_tournament_size_check') then
    alter table public.fa_rooms add constraint fa_rooms_tournament_size_check check (tournament_size is null or tournament_size in (4,8,16));
  end if;
end $$;

create table if not exists public.fa_tournament_matches (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  round_no integer not null check (round_no between 1 and 8),
  match_no integer not null check (match_no >= 1),
  member_a_id uuid null references public.fa_room_members(id) on delete set null,
  member_b_id uuid null references public.fa_room_members(id) on delete set null,
  winner_member_id uuid null references public.fa_room_members(id) on delete set null,
  status text not null default 'pending' check (status in ('pending','completed','bye')),
  seed bigint null,
  team_a jsonb null,
  team_b jsonb null,
  result jsonb null,
  created_at timestamptz not null default now(),
  played_at timestamptz null,
  unique(room_id,round_no,match_no)
);

create index if not exists fa_tournament_matches_room_round_idx
  on public.fa_tournament_matches(room_id,round_no,match_no);

alter table public.fa_tournament_matches enable row level security;

drop policy if exists fa_tournament_matches_select_members on public.fa_tournament_matches;
create policy fa_tournament_matches_select_members
on public.fa_tournament_matches
for select
to authenticated
using (
  exists (
    select 1 from public.fa_room_members m
    where m.room_id=fa_tournament_matches.room_id
      and m.user_id=auth.uid()
      and m.kicked_at is null
  )
);

do $$
begin
  begin
    alter publication supabase_realtime add table public.fa_tournament_matches;
  exception when duplicate_object then null;
  end;
end $$;

create or replace function public.fa_create_tournament_room(
  p_display_name text,
  p_mode text,
  p_budget integer,
  p_tournament_size integer,
  p_reserve_count integer default null,
  p_allow_icons boolean default true,
  p_min_overall integer default 1,
  p_max_overall integer default 100,
  p_allowed_leagues text[] default null,
  p_disconnect_mode text default 'skip',
  p_spectators_allowed boolean default true,
  p_password text default null,
  p_allow_base boolean default true,
  p_allow_specials boolean default true
)
returns table(room_id uuid,room_code text,member_id uuid)
language plpgsql
security definer
set search_path=''
as $function$
declare v_created record;
begin
  if p_tournament_size not in (4,8,16) then raise exception 'tournament size must be 4, 8 or 16'; end if;
  select * into v_created from public.fa_create_room_v3(
    p_display_name,p_mode,p_budget,p_reserve_count,p_allow_icons,p_min_overall,p_max_overall,
    false,p_allowed_leagues,p_disconnect_mode,p_spectators_allowed,p_password,p_allow_base,p_allow_specials
  );
  update public.fa_rooms
  set room_kind='tournament',tournament_size=p_tournament_size,max_players=p_tournament_size
  where id=v_created.room_id;
  return query select v_created.room_id,v_created.room_code,v_created.member_id;
end;
$function$;

create or replace function private.fa_tournament_initialize(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_room public.fa_rooms%rowtype;
  v_count integer;
  v_bracket integer:=2;
  v_matches integer;
  v_byes integer;
  v_members uuid[];
  v_index integer:=1;
  v_match integer;
  v_a uuid;
  v_b uuid;
begin
  select * into v_room from public.fa_rooms where id=p_room_id for update;
  if not found then raise exception 'room not found'; end if;
  if v_room.room_kind<>'tournament' then return jsonb_build_object('initialized',false,'reason','not_tournament'); end if;
  if exists(select 1 from public.fa_tournament_matches where room_id=p_room_id) then
    return jsonb_build_object('initialized',false,'reason','already_initialized');
  end if;

  select count(*) into v_count
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null and m.squad_finalized;

  if v_count<2 then raise exception 'at least two finalized teams are required'; end if;
  if v_count>coalesce(v_room.tournament_size,16) then raise exception 'too many tournament participants'; end if;

  while v_bracket<v_count loop v_bracket:=v_bracket*2; end loop;
  v_matches:=v_bracket/2;
  v_byes:=v_bracket-v_count;

  select array_agg(id order by extensions.gen_random_uuid()) into v_members
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null and m.squad_finalized;

  for v_match in 1..v_byes loop
    v_a:=v_members[v_index]; v_index:=v_index+1;
    insert into public.fa_tournament_matches(room_id,round_no,match_no,member_a_id,member_b_id,winner_member_id,status,played_at)
    values(p_room_id,1,v_match,v_a,null,v_a,'bye',now());
  end loop;

  for v_match in (v_byes+1)..v_matches loop
    v_a:=v_members[v_index]; v_b:=v_members[v_index+1]; v_index:=v_index+2;
    insert into public.fa_tournament_matches(room_id,round_no,match_no,member_a_id,member_b_id,status)
    values(p_room_id,1,v_match,v_a,v_b,'pending');
  end loop;

  return jsonb_build_object('initialized',true,'participants',v_count,'bracket_size',v_bracket,'byes',v_byes,'round_matches',v_matches);
end;
$function$;

create or replace function public.fa_play_tournament_round(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_round integer;
  v_match public.fa_tournament_matches%rowtype;
  v_a jsonb;
  v_b jsonb;
  v_seed bigint;
  v_result jsonb;
  v_winner uuid;
  v_score_a integer;
  v_score_b integer;
  v_pen_a integer;
  v_pen_b integer;
  v_winners uuid[];
  v_count integer;
  v_i integer;
  v_next_round integer;
  v_created integer:=0;
  v_played integer:=0;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  select * into v_room from public.fa_rooms where id=p_room_id for update;
  if not found then raise exception 'room not found'; end if;
  if v_room.room_kind<>'tournament' then raise exception 'not a tournament room'; end if;
  if v_room.host_user_id<>v_user then raise exception 'host only'; end if;
  if v_room.status not in ('squads','finished') then raise exception 'tournament is not ready'; end if;

  if not exists(select 1 from public.fa_tournament_matches where room_id=p_room_id) then
    perform private.fa_tournament_initialize(p_room_id);
  end if;

  if v_room.tournament_champion_member_id is not null then
    return jsonb_build_object('finished',true,'champion_member_id',v_room.tournament_champion_member_id);
  end if;

  select min(round_no) into v_round from public.fa_tournament_matches where room_id=p_room_id and status='pending';
  if v_round is null then select max(round_no) into v_round from public.fa_tournament_matches where room_id=p_room_id; end if;

  for v_match in
    select * from public.fa_tournament_matches
    where room_id=p_room_id and round_no=v_round and status='pending'
    order by match_no for update
  loop
    if v_match.member_a_id is null or v_match.member_b_id is null then raise exception 'invalid tournament pairing'; end if;
    v_a:=private.fa_x1_snapshot(v_match.member_a_id);
    v_b:=private.fa_x1_snapshot(v_match.member_b_id);
    v_seed:=(('x'||encode(extensions.gen_random_bytes(4),'hex'))::bit(32)::bigint % 2147483646)+1;
    v_result:=private.fa_simulate_match_v1(v_a,v_b,v_seed);
    v_score_a:=coalesce((v_result->'score'->>'a')::integer,0);
    v_score_b:=coalesce((v_result->'score'->>'b')::integer,0);

    if v_score_a>v_score_b then
      v_winner:=v_match.member_a_id;
      v_result:=jsonb_set(v_result,'{winner}',to_jsonb(v_winner::text),true)||jsonb_build_object('decided_by','normal_time');
    elsif v_score_b>v_score_a then
      v_winner:=v_match.member_b_id;
      v_result:=jsonb_set(v_result,'{winner}',to_jsonb(v_winner::text),true)||jsonb_build_object('decided_by','normal_time');
    else
      if mod(v_seed,2)=0 then v_winner:=v_match.member_a_id; v_pen_a:=5; v_pen_b:=4;
      else v_winner:=v_match.member_b_id; v_pen_a:=4; v_pen_b:=5; end if;
      v_result:=jsonb_set(v_result,'{winner}',to_jsonb(v_winner::text),true)
        ||jsonb_build_object('decided_by','penalties','penalties',jsonb_build_object('a',v_pen_a,'b',v_pen_b));
    end if;

    update public.fa_tournament_matches
    set status='completed',winner_member_id=v_winner,seed=v_seed,team_a=v_a,team_b=v_b,result=v_result,played_at=now()
    where id=v_match.id;
    v_played:=v_played+1;
  end loop;

  if exists(select 1 from public.fa_tournament_matches where room_id=p_room_id and round_no=v_round and status='pending') then
    return jsonb_build_object('finished',false,'round',v_round,'played',v_played);
  end if;

  select array_agg(winner_member_id order by match_no) into v_winners
  from public.fa_tournament_matches
  where room_id=p_room_id and round_no=v_round and winner_member_id is not null;
  v_count:=coalesce(cardinality(v_winners),0);

  if v_count=1 then
    update public.fa_rooms
    set tournament_champion_member_id=v_winners[1],status='finished'
    where id=p_room_id;
    return jsonb_build_object('finished',true,'round',v_round,'played',v_played,'champion_member_id',v_winners[1]);
  end if;

  if v_count<2 or mod(v_count,2)<>0 then raise exception 'invalid tournament winners count'; end if;
  v_next_round:=v_round+1;

  if not exists(select 1 from public.fa_tournament_matches where room_id=p_room_id and round_no=v_next_round) then
    v_i:=1;
    while v_i<=v_count loop
      insert into public.fa_tournament_matches(room_id,round_no,match_no,member_a_id,member_b_id,status)
      values(p_room_id,v_next_round,((v_i+1)/2),v_winners[v_i],v_winners[v_i+1],'pending');
      v_created:=v_created+1;
      v_i:=v_i+2;
    end loop;
  end if;

  return jsonb_build_object('finished',false,'round',v_round,'played',v_played,'next_round',v_next_round,'next_matches',v_created);
end;
$function$;

create or replace function public.fa_join_room_v2(
  p_code text,p_display_name text,p_password text default null,p_as_spectator boolean default false
)
returns table(room_id uuid,member_id uuid,budget integer,mode text,is_spectator boolean)
language plpgsql security definer set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_member public.fa_room_members%rowtype;
  v_legacy_hash text;
  v_players integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if char_length(trim(p_display_name))<1 or char_length(trim(p_display_name))>24 then raise exception 'invalid display name'; end if;
  select * into v_room from public.fa_rooms r where r.code=upper(trim(p_code)) for update;
  if not found then raise exception 'room not found'; end if;
  select * into v_member from public.fa_room_members m where m.room_id=v_room.id and m.user_id=v_user limit 1;

  if found then
    if v_member.kicked_at is not null then raise exception 'you were removed from this room'; end if;
    update public.fa_room_members set display_name=trim(p_display_name),last_seen_at=now() where id=v_member.id;
    return query select v_room.id,v_member.id,v_room.budget,v_room.mode,v_member.is_spectator;
    return;
  end if;

  if v_room.password_hash is not null then
    if p_password is null then raise exception 'room password required'; end if;
    if v_room.password_hash like '$2%' then
      if extensions.crypt(p_password,v_room.password_hash)<>v_room.password_hash then raise exception 'invalid room password'; end if;
    else
      v_legacy_hash:=encode(extensions.digest(convert_to(p_password,'UTF8'),'sha256'),'hex');
      if v_legacy_hash<>v_room.password_hash then raise exception 'invalid room password'; end if;
    end if;
  end if;

  if v_room.status<>'lobby' and not p_as_spectator then raise exception 'room already started; join as spectator'; end if;
  if p_as_spectator and not v_room.spectators_allowed then raise exception 'spectators are disabled'; end if;

  if not p_as_spectator and v_room.room_kind='tournament' then
    select count(*) into v_players from public.fa_room_members m
    where m.room_id=v_room.id and not m.is_spectator and m.kicked_at is null;
    if v_players>=coalesce(v_room.tournament_size,v_room.max_players) then
      raise exception 'tournament is full; join as spectator';
    end if;
  end if;

  insert into public.fa_room_members(room_id,user_id,display_name,balance,is_host,ready,is_spectator,last_seen_at)
  values(v_room.id,v_user,trim(p_display_name),case when p_as_spectator then 0 else v_room.budget end,false,p_as_spectator,p_as_spectator,now())
  returning * into v_member;
  return query select v_room.id,v_member.id,v_room.budget,v_room.mode,v_member.is_spectator;
end;
$function$;

create or replace function public.fa_finalize_squad(p_room_id uuid)
returns jsonb
language plpgsql security definer set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_member public.fa_room_members%rowtype;
  v_mode text; v_kind text; v_bench_required integer; v_starter_required integer;
  v_starter_count integer; v_bench_count integer; v_ger numeric;
  v_all_finished boolean:=false; v_tournament jsonb:=null;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  update public.fa_room_members set last_seen_at=now() where room_id=p_room_id and user_id=v_user;
  perform private.fa_cleanup_inactive_room(p_room_id);
  select m.* into v_member from public.fa_room_members m where m.room_id=p_room_id and m.user_id=v_user for update;
  if not found then raise exception 'not a room member'; end if;
  if v_member.is_spectator then raise exception 'spectators do not have squads'; end if;

  select r.mode,r.reserve_count,r.room_kind into v_mode,v_bench_required,v_kind from public.fa_rooms r where r.id=p_room_id;
  v_starter_required:=case when v_mode='futsal' then 5 else 11 end;

  if v_mode='futsal' then
    select count(*) into v_starter_count from public.fa_squad_players s
    where s.member_id=v_member.id and s.slot_key in('GOL','FIXO','ALAE','ALAD','PIVO');
  else
    select count(*) into v_starter_count from public.fa_squad_players s
    where s.member_id=v_member.id and s.slot_key in('GOL','LD','ZAG1','ZAG2','LE','VOL','MC','MEI','PD','PE','ATA');
  end if;

  select count(*) into v_bench_count from public.fa_squad_players s
  where s.member_id=v_member.id and s.slot_key like 'BENCH%';

  if v_starter_count<v_starter_required then raise exception 'starting lineup is not complete'; end if;
  if v_bench_count<v_bench_required then raise exception 'bench is not complete'; end if;

  update public.fa_room_members set squad_finalized=true,finalized_at=now(),last_seen_at=now() where id=v_member.id;

  v_all_finished:=not exists(
    select 1 from public.fa_room_members m
    where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
      and m.last_seen_at>=now()-interval '30 seconds' and not m.squad_finalized
  );

  if v_all_finished then
    update public.fa_rooms set status='squads' where id=p_room_id;
    if v_kind='tournament' then v_tournament:=private.fa_tournament_initialize(p_room_id); end if;
  end if;

  select round(avg(p.overall)::numeric,1) into v_ger
  from public.fa_squad_players s join public.fa_players p on p.id=s.player_id
  where s.member_id=v_member.id and s.slot_key not like 'BENCH%';

  return jsonb_build_object(
    'member_id',v_member.id,'finalized',true,'ger',coalesce(v_ger,0),
    'starters',v_starter_count,'bench',v_bench_count,'players',v_starter_count+v_bench_count,
    'all_finished',v_all_finished,'tournament',v_tournament
  );
end;
$function$;

create or replace function public.fa_request_replay(p_room_id uuid)
returns jsonb
language plpgsql security definer set search_path=''
as $function$
declare
  v_user uuid:=auth.uid(); v_room public.fa_rooms%rowtype; v_member public.fa_room_members%rowtype;
  v_requests integer; v_total integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  select * into v_room from public.fa_rooms where id=p_room_id for update;
  if not found then raise exception 'room not found'; end if;
  if v_room.status not in ('squads','finished') then raise exception 'replay is only available after everyone finishes'; end if;
  select * into v_member from public.fa_room_members where room_id=p_room_id and user_id=v_user for update;
  if not found then raise exception 'not a room member'; end if;
  if v_member.is_spectator then raise exception 'spectators cannot request replay'; end if;

  update public.fa_room_members set replay_requested=true,last_seen_at=now() where id=v_member.id;
  select count(*) into v_requests from public.fa_room_members where room_id=p_room_id and not is_spectator and replay_requested;
  select count(*) into v_total from public.fa_room_members where room_id=p_room_id and not is_spectator;

  if v_room.host_user_id<>v_user then
    return jsonb_build_object('restarted',false,'waiting_for_host',true,'requests',v_requests,'total',v_total);
  end if;

  insert into public.fa_round_archives(room_id,snapshot)
  values(p_room_id,jsonb_build_object(
    'players',(select coalesce(jsonb_agg(to_jsonb(p)),'[]'::jsonb) from public.fa_players p where p.room_id=p_room_id),
    'auctions',(select coalesce(jsonb_agg(to_jsonb(a)),'[]'::jsonb) from public.fa_auctions a where a.room_id=p_room_id),
    'bids',(select coalesce(jsonb_agg(to_jsonb(b)),'[]'::jsonb) from public.fa_bids b join public.fa_auctions a on a.id=b.auction_id where a.room_id=p_room_id),
    'squads',(select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb) from public.fa_squad_players s join public.fa_room_members m on m.id=s.member_id where m.room_id=p_room_id),
    'members',(select coalesce(jsonb_agg(jsonb_build_object('id',m.id,'display_name',m.display_name,'balance',m.balance)),'[]'::jsonb) from public.fa_room_members m where m.room_id=p_room_id),
    'tournament_matches',(select coalesce(jsonb_agg(to_jsonb(t) order by t.round_no,t.match_no),'[]'::jsonb) from public.fa_tournament_matches t where t.room_id=p_room_id),
    'tournament_champion_member_id',v_room.tournament_champion_member_id,
    'room_kind',v_room.room_kind
  ));

  update public.fa_x1_matches set status='cancelled',responded_at=now()
  where room_id=p_room_id and status='pending';
  delete from public.fa_tournament_matches where room_id=p_room_id;
  delete from public.fa_squad_players s using public.fa_room_members m where s.member_id=m.id and m.room_id=p_room_id;
  delete from public.fa_auctions where room_id=p_room_id;
  delete from public.fa_players where room_id=p_room_id;

  update public.fa_room_members
  set balance=case when is_spectator then 0 else v_room.budget end,
      squad_finalized=false,finalized_at=null,replay_requested=false,ready=false,
      last_seen_at=case when user_id=v_user then now() else last_seen_at end
  where room_id=p_room_id;

  update public.fa_rooms set status='lobby',tournament_champion_member_id=null where id=p_room_id;
  return jsonb_build_object('restarted',true,'waiting_for_host',false,'requests',0,'total',v_total);
end;
$function$;

revoke all on function public.fa_create_tournament_room(text,text,integer,integer,integer,boolean,integer,integer,text[],text,boolean,text,boolean,boolean) from public;
revoke all on function public.fa_play_tournament_round(uuid) from public;
grant execute on function public.fa_create_tournament_room(text,text,integer,integer,integer,boolean,integer,integer,text[],text,boolean,text,boolean,boolean) to authenticated;
grant execute on function public.fa_play_tournament_round(uuid) to authenticated;
