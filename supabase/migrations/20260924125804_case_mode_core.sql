
alter table public.fa_rooms drop constraint if exists fa_rooms_room_kind_check;
alter table public.fa_rooms
  add constraint fa_rooms_room_kind_check
  check (room_kind in ('auction','tournament','cases'));

create table if not exists public.fa_case_rounds (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  round_no integer not null check (round_no > 0),
  slot_key text not null,
  status text not null default 'choosing'
    check (status in ('choosing','completed')),
  case_count integer not null check (case_count >= 1),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique(room_id,round_no)
);

create table if not exists private.fa_case_options (
  round_id uuid not null references public.fa_case_rounds(id) on delete cascade,
  case_no integer not null check (case_no > 0),
  catalog_id text not null references public.fa_catalog_players(id),
  primary key(round_id,case_no),
  unique(round_id,catalog_id)
);

create table if not exists public.fa_case_picks (
  id uuid primary key default extensions.gen_random_uuid(),
  round_id uuid not null references public.fa_case_rounds(id) on delete cascade,
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  case_no integer not null check (case_no > 0),
  player_id text not null references public.fa_players(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(round_id,member_id),
  unique(round_id,case_no)
);

create index if not exists fa_case_rounds_room_created_idx
  on public.fa_case_rounds(room_id,created_at desc);
create index if not exists fa_case_picks_room_round_idx
  on public.fa_case_picks(room_id,round_id);
create index if not exists fa_case_picks_member_idx
  on public.fa_case_picks(member_id,created_at desc);

alter table public.fa_case_rounds enable row level security;
alter table public.fa_case_picks enable row level security;

drop policy if exists fa_case_rounds_room_select on public.fa_case_rounds;
create policy fa_case_rounds_room_select
on public.fa_case_rounds
for select
to authenticated
using (
  exists(
    select 1
    from public.fa_room_members m
    where m.room_id=fa_case_rounds.room_id
      and m.user_id=(select auth.uid())
      and m.kicked_at is null
  )
);

drop policy if exists fa_case_picks_room_select on public.fa_case_picks;
create policy fa_case_picks_room_select
on public.fa_case_picks
for select
to authenticated
using (
  exists(
    select 1
    from public.fa_room_members m
    where m.room_id=fa_case_picks.room_id
      and m.user_id=(select auth.uid())
      and m.kicked_at is null
  )
);

revoke all on public.fa_case_rounds from public,anon;
revoke all on public.fa_case_picks from public,anon;
grant select on public.fa_case_rounds to authenticated;
grant select on public.fa_case_picks to authenticated;

do $$
begin
  if not exists(
    select 1 from pg_publication_tables
    where pubname='supabase_realtime'
      and schemaname='public'
      and tablename='fa_case_rounds'
  ) then
    alter publication supabase_realtime add table public.fa_case_rounds;
  end if;

  if not exists(
    select 1 from pg_publication_tables
    where pubname='supabase_realtime'
      and schemaname='public'
      and tablename='fa_case_picks'
  ) then
    alter publication supabase_realtime add table public.fa_case_picks;
  end if;
end $$;

create or replace function private.fa_case_slot_sequence(
  p_mode text,
  p_reserve_count integer
)
returns text[]
language plpgsql
immutable
security definer
set search_path=''
as $function$
declare
  v_slots text[];
  i integer;
begin
  if p_mode='futsal' then
    v_slots:=array['GOL','FIXO','ALAE','ALAD','PIVO']::text[];
  else
    v_slots:=array['GOL','LD','ZAG1','ZAG2','LE','VOL','MC','MEI','PD','PE','ATA']::text[];
  end if;

  if coalesce(p_reserve_count,0)>0 then
    for i in 1..p_reserve_count loop
      v_slots:=array_append(v_slots,'BENCH'||i::text);
    end loop;
  end if;

  return v_slots;
end;
$function$;

create or replace function private.fa_case_catalog_matches_slot(
  p_catalog_id text,
  p_slot_key text,
  p_mode text
)
returns boolean
language sql
stable
security definer
set search_path=''
as $function$
  select exists(
    select 1
    from public.fa_catalog_players c
    cross join lateral unnest(array_prepend(c.primary_position,c.secondary_positions)) as pos(raw_position)
    where c.id=p_catalog_id
      and (
        p_slot_key like 'BENCH%'
        or (
          p_mode='football'
          and (
            (p_slot_key='GOL' and private.fa_position_group(pos.raw_position)='GOL')
            or (p_slot_key in ('ZAG1','ZAG2') and private.fa_position_group(pos.raw_position)='ZAG')
            or (
              p_slot_key in ('LD','LE','VOL','MC','MEI','PD','PE','ATA')
              and private.fa_position_group(pos.raw_position)=p_slot_key
            )
          )
        )
        or (
          p_mode='futsal'
          and (
            (p_slot_key='GOL' and private.fa_position_group(pos.raw_position)='GOL')
            or (
              p_slot_key='FIXO'
              and private.fa_position_group(pos.raw_position) in ('ZAG','VOL','LD','LE','MC')
            )
            or (
              p_slot_key='ALAE'
              and private.fa_position_group(pos.raw_position) in ('PE','LE','MC','MEI')
            )
            or (
              p_slot_key='ALAD'
              and private.fa_position_group(pos.raw_position) in ('PD','LD','MC','MEI')
            )
            or (
              p_slot_key='PIVO'
              and private.fa_position_group(pos.raw_position) in ('ATA','MEI')
            )
          )
        )
      )
  );
$function$;

create or replace function private.fa_case_close_round_if_ready(p_round_id uuid)
returns boolean
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_round public.fa_case_rounds%rowtype;
  v_ready boolean;
begin
  select * into v_round
  from public.fa_case_rounds
  where id=p_round_id
  for update;

  if not found then return false; end if;
  if v_round.status='completed' then return true; end if;

  v_ready:=not exists(
    select 1
    from public.fa_room_members m
    where m.room_id=v_round.room_id
      and not m.is_spectator
      and m.kicked_at is null
      and m.last_seen_at>=now()-interval '30 seconds'
      and not exists(
        select 1
        from public.fa_case_picks p
        where p.round_id=v_round.id
          and p.member_id=m.id
      )
  );

  if v_ready then
    update public.fa_case_rounds
    set status='completed',completed_at=coalesce(completed_at,now())
    where id=v_round.id;
  end if;

  return v_ready;
end;
$function$;

create or replace function public.fa_create_case_room(
  p_display_name text,
  p_mode text,
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
declare
  v record;
begin
  select * into v
  from public.fa_create_room_v3(
    p_display_name,
    p_mode,
    1,
    p_reserve_count,
    p_allow_icons,
    p_min_overall,
    p_max_overall,
    false,
    p_allowed_leagues,
    p_disconnect_mode,
    p_spectators_allowed,
    p_password,
    p_allow_base,
    p_allow_specials
  );

  update public.fa_rooms
  set room_kind='cases'
  where id=v.room_id;

  return query select v.room_id,v.room_code,v.member_id;
end;
$function$;

create or replace function public.fa_begin_case_mode(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_active integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only host can start'; end if;
  if v_room.room_kind<>'cases' then raise exception 'not a cases room'; end if;
  if v_room.status<>'lobby' then return to_jsonb(v_room); end if;

  select count(*) into v_active
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds';

  if v_active<2 then raise exception 'at least two active players are required'; end if;

  if exists(
    select 1
    from public.fa_room_members m
    where m.room_id=p_room_id
      and not m.is_spectator
      and m.kicked_at is null
      and m.last_seen_at>=now()-interval '30 seconds'
      and not m.ready
  ) then
    raise exception 'all active players must be ready';
  end if;

  update public.fa_rooms
  set status='auction'
  where id=p_room_id
  returning * into v_room;

  return to_jsonb(v_room);
end;
$function$;

create or replace function public.fa_start_case_round(
  p_room_id uuid,
  p_slot_key text
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_sequence text[];
  v_open public.fa_case_rounds%rowtype;
  v_round public.fa_case_rounds%rowtype;
  v_round_no integer;
  v_active integer;
  v_available integer;
  v_case_count integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only host can choose the position'; end if;
  if v_room.room_kind<>'cases' then raise exception 'not a cases room'; end if;
  if v_room.status<>'auction' then raise exception 'cases mode is not running'; end if;

  select * into v_open
  from public.fa_case_rounds
  where room_id=p_room_id and status='choosing'
  order by round_no desc
  limit 1
  for update;

  if found then
    perform private.fa_case_close_round_if_ready(v_open.id);
    select * into v_open from public.fa_case_rounds where id=v_open.id;
    if v_open.status='choosing' then
      raise exception 'current round is still waiting for picks';
    end if;
  end if;

  v_sequence:=private.fa_case_slot_sequence(v_room.mode,v_room.reserve_count);

  if not (p_slot_key=any(v_sequence)) then
    raise exception 'invalid or unavailable position';
  end if;

  if exists(
    select 1 from public.fa_case_rounds
    where room_id=p_room_id and slot_key=p_slot_key
  ) then
    raise exception 'this position was already used';
  end if;

  select count(*) into v_active
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds';

  if v_active<1 then raise exception 'no active players'; end if;

  select count(*) into v_available
  from public.fa_catalog_players c
  where private.fa_catalog_allowed_for_room(p_room_id,c.id)
    and private.fa_case_catalog_matches_slot(c.id,p_slot_key,v_room.mode)
    and not exists(
      select 1
      from public.fa_players p
      where p.room_id=p_room_id
        and p.catalog_id=c.id
    );

  if v_available<v_active then
    raise exception 'not enough eligible cards for this position';
  end if;

  v_case_count:=least(v_available,v_active+2);

  select coalesce(max(round_no),0)+1 into v_round_no
  from public.fa_case_rounds
  where room_id=p_room_id;

  insert into public.fa_case_rounds(room_id,round_no,slot_key,status,case_count)
  values(p_room_id,v_round_no,p_slot_key,'choosing',v_case_count)
  returning * into v_round;

  insert into private.fa_case_options(round_id,case_no,catalog_id)
  select
    v_round.id,
    row_number() over()::integer,
    c.id
  from (
    select c.id
    from public.fa_catalog_players c
    where private.fa_catalog_allowed_for_room(p_room_id,c.id)
      and private.fa_case_catalog_matches_slot(c.id,p_slot_key,v_room.mode)
      and not exists(
        select 1
        from public.fa_players p
        where p.room_id=p_room_id
          and p.catalog_id=c.id
      )
    order by random()
    limit v_case_count
  ) c;

  return to_jsonb(v_round);
end;
$function$;

create or replace function public.fa_pick_case(
  p_round_id uuid,
  p_case_no integer
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_round public.fa_case_rounds%rowtype;
  v_room public.fa_rooms%rowtype;
  v_member public.fa_room_members%rowtype;
  v_catalog public.fa_catalog_players%rowtype;
  v_catalog_id text;
  v_player_id text;
  v_pick public.fa_case_picks%rowtype;
  v_complete boolean;
  v_sequence text[];
  v_all_done boolean;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_round
  from public.fa_case_rounds
  where id=p_round_id
  for update;

  if not found then raise exception 'round not found'; end if;
  if v_round.status<>'choosing' then raise exception 'round is already completed'; end if;

  select * into v_room
  from public.fa_rooms
  where id=v_round.room_id;

  if v_room.room_kind<>'cases' or v_room.status<>'auction' then
    raise exception 'cases mode is not running';
  end if;

  select * into v_member
  from public.fa_room_members
  where room_id=v_round.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator
  for update;

  if not found then raise exception 'not a room player'; end if;
  if v_member.squad_finalized then raise exception 'squad already finalized'; end if;

  if exists(
    select 1 from public.fa_case_picks
    where round_id=v_round.id and member_id=v_member.id
  ) then
    raise exception 'you already chose a case this round';
  end if;

  if exists(
    select 1 from public.fa_case_picks
    where round_id=v_round.id and case_no=p_case_no
  ) then
    raise exception 'this case was already taken';
  end if;

  select catalog_id into v_catalog_id
  from private.fa_case_options
  where round_id=v_round.id and case_no=p_case_no;

  if v_catalog_id is null then raise exception 'invalid case'; end if;

  select * into v_catalog
  from public.fa_catalog_players
  where id=v_catalog_id;

  v_player_id:=extensions.gen_random_uuid()::text;

  insert into public.fa_players(
    id,room_id,created_by,catalog_id,name,club,league,nationality,
    primary_position,secondary_positions,overall,player_type,image_url,metadata
  )
  values(
    v_player_id,
    v_round.room_id,
    v_user,
    v_catalog.id,
    v_catalog.name,
    v_catalog.club,
    v_catalog.league,
    v_catalog.nationality,
    v_catalog.primary_position,
    v_catalog.secondary_positions,
    v_catalog.overall,
    v_catalog.player_type,
    v_catalog.image_url,
    v_catalog.metadata
  );

  insert into public.fa_squad_players(member_id,player_id,slot_key,is_bench)
  values(
    v_member.id,
    v_player_id,
    v_round.slot_key,
    v_round.slot_key like 'BENCH%'
  );

  insert into public.fa_case_picks(
    round_id,room_id,member_id,case_no,player_id
  )
  values(
    v_round.id,v_round.room_id,v_member.id,p_case_no,v_player_id
  )
  returning * into v_pick;

  update public.fa_room_members
  set last_seen_at=now()
  where id=v_member.id;

  v_complete:=private.fa_case_close_round_if_ready(v_round.id);

  v_sequence:=private.fa_case_slot_sequence(v_room.mode,v_room.reserve_count);

  v_all_done:=not exists(
    select 1
    from unnest(v_sequence) s(slot_key)
    where not exists(
      select 1
      from public.fa_case_rounds r
      where r.room_id=v_round.room_id
        and r.slot_key=s.slot_key
        and r.status='completed'
    )
  );

  return jsonb_build_object(
    'pick',to_jsonb(v_pick),
    'player',(select to_jsonb(p) from public.fa_players p where p.id=v_player_id),
    'round_complete',v_complete,
    'all_slots_done',v_all_done
  );
end;
$function$;

revoke all on function public.fa_create_case_room(text,text,integer,boolean,integer,integer,text[],text,boolean,text,boolean,boolean) from public,anon;
revoke all on function public.fa_begin_case_mode(uuid) from public,anon;
revoke all on function public.fa_start_case_round(uuid,text) from public,anon;
revoke all on function public.fa_pick_case(uuid,integer) from public,anon;

grant execute on function public.fa_create_case_room(text,text,integer,boolean,integer,integer,text[],text,boolean,text,boolean,boolean) to authenticated;
grant execute on function public.fa_begin_case_mode(uuid) to authenticated;
grant execute on function public.fa_start_case_round(uuid,text) to authenticated;
grant execute on function public.fa_pick_case(uuid,integer) to authenticated;
