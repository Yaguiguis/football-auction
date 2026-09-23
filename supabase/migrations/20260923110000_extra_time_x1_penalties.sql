create schema if not exists private;

alter table public.fa_x1_matches drop constraint if exists fa_x1_matches_status_check;
alter table public.fa_x1_matches
  add constraint fa_x1_matches_status_check
  check (status in ('pending','declined','shootout','completed','cancelled'));

create table if not exists private.fa_x1_penalty_choices (
  match_id uuid not null references public.fa_x1_matches(id) on delete cascade,
  kick_no integer not null check (kick_no > 0),
  role text not null check (role in ('shot','keeper')),
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  direction text not null check (direction in ('left','center','right')),
  created_at timestamptz not null default now(),
  primary key(match_id,kick_no,role)
);

create or replace function private.fa_simulate_knockout_match_v2(a jsonb,b jsonb,seed bigint,p_auto_penalties boolean default false)
returns jsonb
language plpgsql
immutable
set search_path=''
as $function$
declare
  sa jsonb:=private.fa_x1_strength(a);
  sb jsonb:=private.fa_x1_strength(b);
  state bigint:=greatest(1,coalesce(seed,1));
  fa double precision:=coalesce((sa->>'form')::double precision,0);
  fb double precision:=coalesce((sb->>'form')::double precision,0);
  xa double precision:=greatest(0.45,least(3.4,1.1+(fa-fb)*0.09+((sa->>'attack')::double precision)*0.012));
  xb double precision:=greatest(0.45,least(3.4,1.1+(fb-fa)*0.09+((sb->>'attack')::double precision)*0.012));
  chance double precision;
  choice double precision;
  minute integer;
  side text;
  pool jsonb;
  scorer text;
  goals_a integer:=0;
  goals_b integer:=0;
  extra_a integer:=0;
  extra_b integer:=0;
  events jsonb:='[]'::jsonb;
  result jsonb;
  kick_index integer:=1;
  kick_team text;
  shot text;
  keeper text;
  dirs text[]:=array['left','center','right'];
  goal boolean;
  kicks jsonb:='[]'::jsonb;
  pen_a integer:=0;
  pen_b integer:=0;
  taken_a integer:=0;
  taken_b integer:=0;
  remaining_a integer;
  remaining_b integer;
  winner text;
begin
  if seed<1 then state:=1; end if;

  for minute in 1..90 loop
    state:=mod(state*48271,2147483647); chance:=state::double precision/2147483647.0;
    if chance<((xa+xb)/90.0) then
      state:=mod(state*48271,2147483647); choice:=state::double precision/2147483647.0;
      if choice<xa/(xa+xb) then side:='a'; goals_a:=goals_a+1; pool:=a->'players';
      else side:='b'; goals_b:=goals_b+1; pool:=b->'players'; end if;
      state:=mod(state*48271,2147483647);
      scorer:=coalesce(pool->(state % greatest(1,jsonb_array_length(pool)))::integer->>'name',case when side='a' then a->>'name' else b->>'name' end);
      events:=events||jsonb_build_array(jsonb_build_object('minute',minute,'team',side,'type','goal','player',scorer,'score',jsonb_build_object('a',goals_a,'b',goals_b)));
    elsif chance<((xa+xb)/90.0)+0.018 then
      state:=mod(state*48271,2147483647); choice:=state::double precision/2147483647.0;
      side:=case when choice<0.5 then 'a' else 'b' end;
      pool:=case when side='a' then a->'players' else b->'players' end;
      state:=mod(state*48271,2147483647);
      scorer:=coalesce(pool->(state % greatest(1,jsonb_array_length(pool)))::integer->>'name',case when side='a' then a->>'name' else b->>'name' end);
      events:=events||jsonb_build_array(jsonb_build_object('minute',minute,'team',side,'type','chance','player',scorer));
    end if;
  end loop;

  result:=jsonb_build_object(
    'version','x1-v2',
    'seed',seed,
    'score',jsonb_build_object('a',goals_a,'b',goals_b),
    'winner',case when goals_a=goals_b then null when goals_a>goals_b then a->>'id' else b->>'id' end,
    'events',events,
    'strength',jsonb_build_object('a',sa,'b',sb),
    'xg',jsonb_build_object('a',xa,'b',xb)
  );

  if goals_a<>goals_b then
    return result||jsonb_build_object('decided_by','normal_time');
  end if;

  for minute in 91..120 loop
    state:=mod(state*48271,2147483647); chance:=state::double precision/2147483647.0;
    if chance<((xa+xb)/90.0) then
      state:=mod(state*48271,2147483647); choice:=state::double precision/2147483647.0;
      if choice<xa/(xa+xb) then side:='a'; goals_a:=goals_a+1; extra_a:=extra_a+1; pool:=a->'players';
      else side:='b'; goals_b:=goals_b+1; extra_b:=extra_b+1; pool:=b->'players'; end if;
      state:=mod(state*48271,2147483647);
      scorer:=coalesce(pool->(state % greatest(1,jsonb_array_length(pool)))::integer->>'name',case when side='a' then a->>'name' else b->>'name' end);
      events:=events||jsonb_build_array(jsonb_build_object('minute',minute,'team',side,'type','goal','player',scorer,'score',jsonb_build_object('a',goals_a,'b',goals_b)));
    elsif chance<((xa+xb)/90.0)+0.012 then
      state:=mod(state*48271,2147483647); choice:=state::double precision/2147483647.0;
      side:=case when choice<0.5 then 'a' else 'b' end;
      pool:=case when side='a' then a->'players' else b->'players' end;
      state:=mod(state*48271,2147483647);
      scorer:=coalesce(pool->(state % greatest(1,jsonb_array_length(pool)))::integer->>'name',case when side='a' then a->>'name' else b->>'name' end);
      events:=events||jsonb_build_array(jsonb_build_object('minute',minute,'team',side,'type','chance','player',scorer));
    end if;
  end loop;

  result:=jsonb_set(result,'{score}',jsonb_build_object('a',goals_a,'b',goals_b),true);
  result:=jsonb_set(result,'{events}',events,true);
  result:=result||jsonb_build_object('extra_time',jsonb_build_object('score',jsonb_build_object('a',extra_a,'b',extra_b)));

  if goals_a<>goals_b then
    return jsonb_set(result,'{winner}',to_jsonb(case when goals_a>goals_b then a->>'id' else b->>'id' end),true)||jsonb_build_object('decided_by','extra_time');
  end if;

  result:=jsonb_set(result,'{winner}','null'::jsonb,true)
    ||jsonb_build_object(
      'decided_by','penalties',
      'penalties',jsonb_build_object('a',0,'b',0),
      'penalty_shootout',jsonb_build_object(
        'score',jsonb_build_object('a',0,'b',0),
        'kicks','[]'::jsonb,
        'status','pending',
        'next',jsonb_build_object('index',1,'team','a','suddenDeath',false)
      )
    );

  if not p_auto_penalties then
    return result;
  end if;

  loop
    kick_team:=case when mod(kick_index,2)=1 then 'a' else 'b' end;
    state:=mod(state*48271,2147483647); shot:=dirs[(state % 3)+1];
    state:=mod(state*48271,2147483647); keeper:=dirs[(state % 3)+1];
    goal:=shot<>keeper;
    if kick_team='a' then taken_a:=taken_a+1; if goal then pen_a:=pen_a+1; end if;
    else taken_b:=taken_b+1; if goal then pen_b:=pen_b+1; end if; end if;
    kicks:=kicks||jsonb_build_array(jsonb_build_object('index',kick_index,'team',kick_team,'shot',shot,'keeper',keeper,'goal',goal));

    remaining_a:=greatest(0,5-taken_a);
    remaining_b:=greatest(0,5-taken_b);
    if (taken_a<=5 and taken_b<=5 and (pen_a>pen_b+remaining_b or pen_b>pen_a+remaining_a))
      or (taken_a>=5 and taken_b>=5 and taken_a=taken_b and pen_a<>pen_b) then
      winner:=case when pen_a>pen_b then a->>'id' else b->>'id' end;
      return jsonb_set(result,'{winner}',to_jsonb(winner),true)
        ||jsonb_build_object(
          'penalties',jsonb_build_object('a',pen_a,'b',pen_b),
          'penalty_shootout',jsonb_build_object('score',jsonb_build_object('a',pen_a,'b',pen_b),'kicks',kicks,'status','completed')
        );
    end if;
    kick_index:=kick_index+1;
  end loop;
end;
$function$;

create or replace function public.fa_respond_x1(p_match_id uuid,p_accept boolean)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_a jsonb;
  v_b jsonb;
  v_seed bigint;
  v_result jsonb;
  v_status text;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  select * into v_me from public.fa_room_members where room_id=v_match.room_id and user_id=v_user and kicked_at is null;
  if not found or v_me.id<>v_match.opponent_id then raise exception 'only challenged player can respond'; end if;
  if v_match.status<>'pending' then
    return to_jsonb(v_match);
  end if;

  if not p_accept then
    update public.fa_x1_matches set status='declined',responded_at=now() where id=v_match.id returning * into v_match;
    return to_jsonb(v_match);
  end if;

  v_a:=private.fa_x1_snapshot(v_match.challenger_id);
  v_b:=private.fa_x1_snapshot(v_match.opponent_id);
  v_seed:=(('x'||encode(extensions.gen_random_bytes(4),'hex'))::bit(32)::bigint % 2147483646)+1;
  v_result:=private.fa_simulate_knockout_match_v2(v_a,v_b,v_seed,false);
  v_status:=case when v_result->>'decided_by'='penalties' and v_result->>'winner' is null then 'shootout' else 'completed' end;

  update public.fa_x1_matches
  set status=v_status,team_a=v_a,team_b=v_b,result=v_result,seed=v_seed,responded_at=now(),completed_at=case when v_status='completed' then now() else null end
  where id=v_match.id
  returning * into v_match;
  return to_jsonb(v_match);
end;
$function$;

create or replace function public.fa_choose_x1_penalty(p_match_id uuid,p_direction text)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_next jsonb;
  v_team text;
  v_kick_no integer;
  v_role text;
  v_shooter uuid;
  v_keeper uuid;
  v_shot text;
  v_keep text;
  v_goal boolean;
  v_kicks jsonb;
  v_score_a integer;
  v_score_b integer;
  v_taken_a integer;
  v_taken_b integer;
  v_remaining_a integer;
  v_remaining_b integer;
  v_complete boolean:=false;
  v_winner text;
  v_next_team text;
  v_result jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if p_direction not in ('left','center','right') then raise exception 'invalid penalty direction'; end if;

  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  if v_match.status<>'shootout' then return to_jsonb(v_match); end if;

  select * into v_me from public.fa_room_members
  where room_id=v_match.room_id and user_id=v_user and kicked_at is null and not is_spectator;
  if not found then raise exception 'player not found'; end if;

  v_next:=v_match.result#>'{penalty_shootout,next}';
  if v_next is null then raise exception 'shootout is not accepting choices'; end if;
  v_team:=v_next->>'team';
  v_kick_no:=coalesce((v_next->>'index')::integer,1);

  if v_team='a' then v_shooter:=v_match.challenger_id; v_keeper:=v_match.opponent_id;
  else v_shooter:=v_match.opponent_id; v_keeper:=v_match.challenger_id; end if;

  if v_me.id=v_shooter then v_role:='shot';
  elsif v_me.id=v_keeper then v_role:='keeper';
  else raise exception 'not a match player'; end if;

  insert into private.fa_x1_penalty_choices(match_id,kick_no,role,member_id,direction)
  values(v_match.id,v_kick_no,v_role,v_me.id,p_direction)
  on conflict(match_id,kick_no,role) do update
    set member_id=excluded.member_id,direction=excluded.direction,created_at=now();

  select
    max(direction) filter (where role='shot'),
    max(direction) filter (where role='keeper')
  into v_shot,v_keep
  from private.fa_x1_penalty_choices
  where match_id=v_match.id and kick_no=v_kick_no;

  if v_shot is null or v_keep is null then
    select * into v_match from public.fa_x1_matches where id=p_match_id;
    return to_jsonb(v_match);
  end if;

  v_goal:=v_shot<>v_keep;
  v_score_a:=coalesce((v_match.result#>>'{penalty_shootout,score,a}')::integer,0);
  v_score_b:=coalesce((v_match.result#>>'{penalty_shootout,score,b}')::integer,0);
  if v_team='a' and v_goal then v_score_a:=v_score_a+1; end if;
  if v_team='b' and v_goal then v_score_b:=v_score_b+1; end if;

  v_kicks:=coalesce(v_match.result#>'{penalty_shootout,kicks}','[]'::jsonb)
    ||jsonb_build_array(jsonb_build_object('index',v_kick_no,'team',v_team,'shot',v_shot,'keeper',v_keep,'goal',v_goal));

  select
    count(*) filter (where value->>'team'='a'),
    count(*) filter (where value->>'team'='b')
  into v_taken_a,v_taken_b
  from jsonb_array_elements(v_kicks);

  v_remaining_a:=greatest(0,5-v_taken_a);
  v_remaining_b:=greatest(0,5-v_taken_b);
  if (v_taken_a<=5 and v_taken_b<=5 and (v_score_a>v_score_b+v_remaining_b or v_score_b>v_score_a+v_remaining_a))
    or (v_taken_a>=5 and v_taken_b>=5 and v_taken_a=v_taken_b and v_score_a<>v_score_b) then
    v_complete:=true;
    v_winner:=case when v_score_a>v_score_b then v_match.challenger_id::text else v_match.opponent_id::text end;
  end if;

  if v_complete then
    v_result:=jsonb_set(v_match.result,'{winner}',to_jsonb(v_winner),true);
    v_result:=jsonb_set(v_result,'{penalties}',jsonb_build_object('a',v_score_a,'b',v_score_b),true);
    v_result:=jsonb_set(v_result,'{penalty_shootout}',jsonb_build_object('score',jsonb_build_object('a',v_score_a,'b',v_score_b),'kicks',v_kicks,'status','completed'),true);
    update public.fa_x1_matches
    set status='completed',result=v_result,completed_at=now()
    where id=v_match.id
    returning * into v_match;
    delete from private.fa_x1_penalty_choices where match_id=v_match.id;
    return to_jsonb(v_match);
  end if;

  v_next_team:=case when v_team='a' then 'b' else 'a' end;
  v_result:=jsonb_set(v_match.result,'{penalties}',jsonb_build_object('a',v_score_a,'b',v_score_b),true);
  v_result:=jsonb_set(v_result,'{penalty_shootout}',jsonb_build_object(
    'score',jsonb_build_object('a',v_score_a,'b',v_score_b),
    'kicks',v_kicks,
    'status','pending',
    'next',jsonb_build_object('index',v_kick_no+1,'team',v_next_team,'suddenDeath',(v_taken_a>=5 and v_taken_b>=5))
  ),true);

  update public.fa_x1_matches
  set result=v_result
  where id=v_match.id
  returning * into v_match;
  delete from private.fa_x1_penalty_choices where match_id=v_match.id and kick_no=v_kick_no;
  return to_jsonb(v_match);
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
    v_result:=private.fa_simulate_knockout_match_v2(v_a,v_b,v_seed,true);
    v_winner:=(v_result->>'winner')::uuid;
    if v_winner is null then raise exception 'knockout simulation did not produce a winner'; end if;

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

revoke all on function private.fa_simulate_knockout_match_v2(jsonb,jsonb,bigint,boolean) from public,anon,authenticated;
revoke all on function public.fa_respond_x1(uuid,boolean), public.fa_choose_x1_penalty(uuid,text), public.fa_play_tournament_round(uuid) from public,anon;
grant execute on function public.fa_respond_x1(uuid,boolean), public.fa_choose_x1_penalty(uuid,text), public.fa_play_tournament_round(uuid) to authenticated;
