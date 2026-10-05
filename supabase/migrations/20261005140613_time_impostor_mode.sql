
alter table public.fa_rooms drop constraint if exists fa_rooms_room_kind_check;
alter table public.fa_rooms
  add constraint fa_rooms_room_kind_check
  check (room_kind in ('auction','tournament','cases','impostor','time_impostor'));

create table if not exists public.fa_time_impostor_games (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  impostor_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  status text not null default 'playing'
    check (status in ('playing','finished')),
  phase text not null default 'admin_setup'
    check (phase in ('admin_setup','timing','reveal','decision','elimination','runoff','finished')),
  round_no integer not null default 1 check (round_no > 0),
  active_round_id uuid,
  vote_stage integer not null default 1 check (vote_stage in (1,2)),
  runoff_candidates uuid[],
  last_decision jsonb,
  last_elimination jsonb,
  winner_side text check (winner_side is null or winner_side in ('innocents','impostor')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  finished_at timestamptz
);

create index if not exists fa_time_impostor_games_room_created_idx
  on public.fa_time_impostor_games(room_id,created_at desc);

create table if not exists public.fa_time_impostor_rounds (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_time_impostor_games(id) on delete cascade,
  round_no integer not null check (round_no > 0),
  status text not null default 'timing'
    check (status in ('timing','revealed','completed')),
  created_at timestamptz not null default now(),
  revealed_at timestamptz,
  completed_at timestamptz,
  unique(game_id,round_no)
);

alter table public.fa_time_impostor_games
  drop constraint if exists fa_time_impostor_games_active_round_fkey;
alter table public.fa_time_impostor_games
  add constraint fa_time_impostor_games_active_round_fkey
  foreign key(active_round_id)
  references public.fa_time_impostor_rounds(id)
  on delete set null;

create table if not exists private.fa_time_impostor_targets (
  round_id uuid primary key references public.fa_time_impostor_rounds(id) on delete cascade,
  target_ms integer not null check (target_ms between 1000 and 300000)
);

create table if not exists public.fa_time_impostor_timers (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  round_id uuid not null references public.fa_time_impostor_rounds(id) on delete cascade,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  started_at timestamptz,
  stopped_at timestamptz,
  elapsed_ms integer check (elapsed_ms is null or elapsed_ms >= 0),
  created_at timestamptz not null default now(),
  unique(round_id,member_id)
);

create index if not exists fa_time_impostor_timers_round_idx
  on public.fa_time_impostor_timers(round_id);

create table if not exists public.fa_time_impostor_decision_votes (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_time_impostor_games(id) on delete cascade,
  round_no integer not null,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  choice text not null check (choice in ('vote','continue')),
  created_at timestamptz not null default now(),
  unique(game_id,round_no,member_id)
);

create index if not exists fa_time_impostor_decision_game_round_idx
  on public.fa_time_impostor_decision_votes(game_id,round_no);

create table if not exists public.fa_time_impostor_elimination_votes (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_time_impostor_games(id) on delete cascade,
  round_no integer not null,
  stage integer not null check (stage in (1,2)),
  voter_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  target_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(game_id,round_no,stage,voter_member_id),
  check (voter_member_id<>target_member_id)
);

create index if not exists fa_time_impostor_elimination_game_round_idx
  on public.fa_time_impostor_elimination_votes(game_id,round_no,stage);

create table if not exists public.fa_time_impostor_eliminations (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_time_impostor_games(id) on delete cascade,
  round_no integer not null,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  was_impostor boolean not null,
  created_at timestamptz not null default now(),
  unique(game_id,member_id)
);

create index if not exists fa_time_impostor_eliminations_game_idx
  on public.fa_time_impostor_eliminations(game_id,created_at);

alter table public.fa_time_impostor_games enable row level security;
alter table public.fa_time_impostor_rounds enable row level security;
alter table public.fa_time_impostor_timers enable row level security;
alter table public.fa_time_impostor_decision_votes enable row level security;
alter table public.fa_time_impostor_elimination_votes enable row level security;
alter table public.fa_time_impostor_eliminations enable row level security;

revoke all on public.fa_time_impostor_games from public,anon,authenticated;
revoke all on public.fa_time_impostor_rounds from public,anon,authenticated;
revoke all on public.fa_time_impostor_timers from public,anon,authenticated;
revoke all on public.fa_time_impostor_decision_votes from public,anon,authenticated;
revoke all on public.fa_time_impostor_elimination_votes from public,anon,authenticated;
revoke all on public.fa_time_impostor_eliminations from public,anon,authenticated;

create or replace function private.fa_time_impostor_member_alive(
  p_game_id uuid,
  p_member_id uuid
)
returns boolean
language sql
stable
security definer
set search_path=''
as $function$
  select exists(
    select 1
    from public.fa_time_impostor_games g
    join public.fa_room_members m
      on m.room_id=g.room_id
     and m.id=p_member_id
    where g.id=p_game_id
      and not m.is_spectator
      and m.kicked_at is null
      and not exists(
        select 1
        from public.fa_time_impostor_eliminations e
        where e.game_id=g.id
          and e.member_id=m.id
      )
  );
$function$;

create or replace function private.fa_time_impostor_new_round(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path=''
as $function$
begin
  update public.fa_time_impostor_games
  set round_no=round_no+1,
      phase='admin_setup',
      active_round_id=null,
      vote_stage=1,
      runoff_candidates=null,
      updated_at=now()
  where id=p_game_id
    and status='playing';
end;
$function$;

create or replace function private.fa_time_impostor_resolve_elimination(
  p_game_id uuid,
  p_member_id uuid,
  p_vote_summary jsonb
)
returns void
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_game public.fa_time_impostor_games%rowtype;
  v_was_impostor boolean;
  v_alive integer;
begin
  select * into v_game
  from public.fa_time_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing' then
    return;
  end if;

  if not private.fa_time_impostor_member_alive(v_game.id,p_member_id) then
    raise exception 'target is not alive';
  end if;

  v_was_impostor:=p_member_id=v_game.impostor_member_id;

  insert into public.fa_time_impostor_eliminations(
    room_id,game_id,round_no,member_id,was_impostor
  )
  values(
    v_game.room_id,v_game.id,v_game.round_no,p_member_id,v_was_impostor
  )
  on conflict(game_id,member_id) do nothing;

  update public.fa_time_impostor_games
  set last_elimination=jsonb_build_object(
        'round',v_game.round_no,
        'member_id',p_member_id,
        'was_impostor',v_was_impostor,
        'votes',p_vote_summary
      ),
      updated_at=now()
  where id=v_game.id;

  if v_was_impostor then
    update public.fa_time_impostor_games
    set status='finished',
        phase='finished',
        winner_side='innocents',
        active_round_id=null,
        finished_at=now(),
        updated_at=now()
    where id=v_game.id;

    update public.fa_rooms
    set status='finished'
    where id=v_game.room_id;

    return;
  end if;

  select count(*) into v_alive
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_time_impostor_eliminations e
      where e.game_id=v_game.id
        and e.member_id=m.id
    );

  if v_alive<=2 then
    update public.fa_time_impostor_games
    set status='finished',
        phase='finished',
        winner_side='impostor',
        active_round_id=null,
        finished_at=now(),
        updated_at=now()
    where id=v_game.id;

    update public.fa_rooms
    set status='finished'
    where id=v_game.room_id;

    return;
  end if;

  perform private.fa_time_impostor_new_round(v_game.id);
end;
$function$;

create or replace function public.fa_create_time_impostor_room(
  p_display_name text,
  p_spectators_allowed boolean default true,
  p_password text default null
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
    'futsal',
    100,
    0,
    true,
    1,
    100,
    false,
    null,
    'skip',
    p_spectators_allowed,
    p_password,
    true,
    true
  );

  update public.fa_rooms
  set room_kind='time_impostor',
      max_players=2147483647
  where id=v.room_id;

  update public.fa_room_members
  set is_spectator=true,
      ready=false,
      balance=0
  where id=v.member_id;

  return query select v.room_id,v.room_code,v.member_id;
end;
$function$;

create or replace function public.fa_begin_time_impostor_mode(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_count integer;
  v_impostor uuid;
  v_game public.fa_time_impostor_games%rowtype;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only host can start'; end if;
  if v_room.room_kind<>'time_impostor' then raise exception 'not a time impostor room'; end if;
  if v_room.status<>'lobby' then raise exception 'room is not in lobby'; end if;

  select count(*) into v_count
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds';

  if v_count<4 then
    raise exception 'at least four active players are required';
  end if;

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

  select m.id into v_impostor
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by random()
  limit 1;

  insert into public.fa_time_impostor_games(
    room_id,impostor_member_id,status,phase,round_no
  )
  values(
    p_room_id,v_impostor,'playing','admin_setup',1
  )
  returning * into v_game;

  update public.fa_rooms
  set status='auction'
  where id=p_room_id;

  return jsonb_build_object(
    'id',v_game.id,
    'status',v_game.status,
    'phase',v_game.phase,
    'round_no',v_game.round_no
  );
end;
$function$;

create or replace function public.fa_time_impostor_start_round(
  p_game_id uuid,
  p_target_seconds numeric
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_game public.fa_time_impostor_games%rowtype;
  v_room public.fa_rooms%rowtype;
  v_round public.fa_time_impostor_rounds%rowtype;
  v_target_ms integer;
  v_count integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_game
  from public.fa_time_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing' then raise exception 'game not active'; end if;
  if v_game.phase<>'admin_setup' then raise exception 'round is not waiting for target'; end if;

  select * into v_room
  from public.fa_rooms
  where id=v_game.room_id;

  if v_room.host_user_id<>v_user then raise exception 'only admin can set target time'; end if;

  v_target_ms:=round(p_target_seconds*1000)::integer;

  if v_target_ms<1000 or v_target_ms>300000 then
    raise exception 'target time must be between 1 and 300 seconds';
  end if;

  select count(*) into v_count
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_time_impostor_eliminations e
      where e.game_id=v_game.id
        and e.member_id=m.id
    );

  if v_count<3 then raise exception 'not enough alive players'; end if;

  insert into public.fa_time_impostor_rounds(
    room_id,game_id,round_no,status
  )
  values(
    v_game.room_id,v_game.id,v_game.round_no,'timing'
  )
  returning * into v_round;

  insert into private.fa_time_impostor_targets(round_id,target_ms)
  values(v_round.id,v_target_ms);

  insert into public.fa_time_impostor_timers(room_id,round_id,member_id)
  select v_game.room_id,v_round.id,m.id
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_time_impostor_eliminations e
      where e.game_id=v_game.id
        and e.member_id=m.id
    );

  update public.fa_time_impostor_games
  set phase='timing',
      active_round_id=v_round.id,
      updated_at=now()
  where id=v_game.id;

  return jsonb_build_object(
    'round_id',v_round.id,
    'round_no',v_round.round_no,
    'phase','timing'
  );
end;
$function$;

create or replace function public.fa_time_impostor_start_timer(p_round_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_round public.fa_time_impostor_rounds%rowtype;
  v_game public.fa_time_impostor_games%rowtype;
  v_me public.fa_room_members%rowtype;
  v_timer public.fa_time_impostor_timers%rowtype;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_round
  from public.fa_time_impostor_rounds
  where id=p_round_id
  for update;

  if not found or v_round.status<>'timing' then raise exception 'round is not active'; end if;

  select * into v_game
  from public.fa_time_impostor_games
  where id=v_round.game_id
  for update;

  if v_game.status<>'playing' or v_game.phase<>'timing'
     or v_game.active_round_id<>v_round.id
  then
    raise exception 'timing phase is not active';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_game.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found or not private.fa_time_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  update public.fa_time_impostor_timers
  set started_at=coalesce(started_at,clock_timestamp())
  where round_id=v_round.id
    and member_id=v_me.id
  returning * into v_timer;

  if not found then raise exception 'timer not found'; end if;
  if v_timer.stopped_at is not null then raise exception 'timer already stopped'; end if;

  return jsonb_build_object('started',true);
end;
$function$;

create or replace function public.fa_time_impostor_stop_timer(p_round_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_round public.fa_time_impostor_rounds%rowtype;
  v_game public.fa_time_impostor_games%rowtype;
  v_me public.fa_room_members%rowtype;
  v_timer public.fa_time_impostor_timers%rowtype;
  v_elapsed integer;
  v_pending integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_round
  from public.fa_time_impostor_rounds
  where id=p_round_id
  for update;

  if not found or v_round.status<>'timing' then raise exception 'round is not active'; end if;

  select * into v_game
  from public.fa_time_impostor_games
  where id=v_round.game_id
  for update;

  if v_game.status<>'playing' or v_game.phase<>'timing'
     or v_game.active_round_id<>v_round.id
  then
    raise exception 'timing phase is not active';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_game.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found or not private.fa_time_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  select * into v_timer
  from public.fa_time_impostor_timers
  where round_id=v_round.id
    and member_id=v_me.id
  for update;

  if not found then raise exception 'timer not found'; end if;
  if v_timer.started_at is null then raise exception 'start your timer first'; end if;

  if v_timer.stopped_at is null then
    v_elapsed:=greatest(
      0,
      round(extract(epoch from (clock_timestamp()-v_timer.started_at))*1000)::integer
    );

    update public.fa_time_impostor_timers
    set stopped_at=clock_timestamp(),
        elapsed_ms=v_elapsed
    where id=v_timer.id
    returning * into v_timer;
  end if;

  select count(*) into v_pending
  from public.fa_time_impostor_timers t
  where t.round_id=v_round.id
    and t.stopped_at is null;

  if v_pending=0 then
    update public.fa_time_impostor_rounds
    set status='revealed',revealed_at=now()
    where id=v_round.id;

    update public.fa_time_impostor_games
    set phase='reveal',updated_at=now()
    where id=v_game.id;
  else
    update public.fa_time_impostor_games
    set updated_at=now()
    where id=v_game.id;
  end if;

  return jsonb_build_object(
    'stopped',true,
    'round_revealed',v_pending=0
  );
end;
$function$;

create or replace function public.fa_time_impostor_open_decision(p_game_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_game public.fa_time_impostor_games%rowtype;
  v_room public.fa_rooms%rowtype;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_game
  from public.fa_time_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing' or v_game.phase<>'reveal' then
    raise exception 'reveal phase is not active';
  end if;

  select * into v_room from public.fa_rooms where id=v_game.room_id;
  if v_room.host_user_id<>v_user then raise exception 'only admin can continue'; end if;

  update public.fa_time_impostor_rounds
  set status='completed',completed_at=now()
  where id=v_game.active_round_id;

  update public.fa_time_impostor_games
  set phase='decision',updated_at=now()
  where id=v_game.id;

  return jsonb_build_object('phase','decision');
end;
$function$;

create or replace function public.fa_time_impostor_decide_round(
  p_game_id uuid,
  p_choice text
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_game public.fa_time_impostor_games%rowtype;
  v_me public.fa_room_members%rowtype;
  v_alive integer;
  v_total integer;
  v_vote integer;
  v_continue integer;
  v_result jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if p_choice not in ('vote','continue') then raise exception 'invalid choice'; end if;

  select * into v_game
  from public.fa_time_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing' or v_game.phase<>'decision' then
    raise exception 'decision phase is not active';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_game.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found or not private.fa_time_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  insert into public.fa_time_impostor_decision_votes(
    room_id,game_id,round_no,member_id,choice
  )
  values(v_game.room_id,v_game.id,v_game.round_no,v_me.id,p_choice)
  on conflict(game_id,round_no,member_id) do update set
    choice=excluded.choice;

  select count(*) into v_alive
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_time_impostor_eliminations e
      where e.game_id=v_game.id and e.member_id=m.id
    );

  select count(*) into v_total
  from public.fa_time_impostor_decision_votes d
  where d.game_id=v_game.id and d.round_no=v_game.round_no;

  if v_total<v_alive then
    update public.fa_time_impostor_games set updated_at=now() where id=v_game.id;
    return jsonb_build_object('complete',false,'submitted',true);
  end if;

  select
    count(*) filter(where d.choice='vote'),
    count(*) filter(where d.choice='continue')
  into v_vote,v_continue
  from public.fa_time_impostor_decision_votes d
  where d.game_id=v_game.id and d.round_no=v_game.round_no;

  v_result:=jsonb_build_object(
    'round',v_game.round_no,
    'vote',v_vote,
    'continue',v_continue,
    'tie',v_vote=v_continue,
    'result',case when v_vote>v_continue then 'vote' else 'continue' end
  );

  update public.fa_time_impostor_games
  set last_decision=v_result,updated_at=now()
  where id=v_game.id;

  if v_vote>v_continue then
    update public.fa_time_impostor_games
    set phase='elimination',
        vote_stage=1,
        runoff_candidates=null,
        updated_at=now()
    where id=v_game.id;
  else
    perform private.fa_time_impostor_new_round(v_game.id);
  end if;

  return v_result || jsonb_build_object('complete',true);
end;
$function$;

create or replace function public.fa_time_impostor_vote_elimination(
  p_game_id uuid,
  p_target_member_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_game public.fa_time_impostor_games%rowtype;
  v_me public.fa_room_members%rowtype;
  v_alive integer;
  v_total integer;
  v_stage integer;
  v_max integer;
  v_tied uuid[];
  v_summary jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_game
  from public.fa_time_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing'
     or v_game.phase not in ('elimination','runoff')
  then
    raise exception 'elimination vote is not active';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_game.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found or not private.fa_time_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  if p_target_member_id=v_me.id then raise exception 'you cannot vote for yourself'; end if;
  if not private.fa_time_impostor_member_alive(v_game.id,p_target_member_id) then
    raise exception 'target is not active';
  end if;

  v_stage:=case when v_game.phase='runoff' then 2 else 1 end;

  if v_stage=2 and not (
    p_target_member_id=any(coalesce(v_game.runoff_candidates,array[]::uuid[]))
  ) then
    raise exception 'target is not in runoff';
  end if;

  insert into public.fa_time_impostor_elimination_votes(
    room_id,game_id,round_no,stage,voter_member_id,target_member_id
  )
  values(
    v_game.room_id,v_game.id,v_game.round_no,v_stage,v_me.id,p_target_member_id
  )
  on conflict(game_id,round_no,stage,voter_member_id) do update set
    target_member_id=excluded.target_member_id;

  select count(*) into v_alive
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_time_impostor_eliminations e
      where e.game_id=v_game.id and e.member_id=m.id
    );

  select count(*) into v_total
  from public.fa_time_impostor_elimination_votes v
  where v.game_id=v_game.id
    and v.round_no=v_game.round_no
    and v.stage=v_stage;

  if v_total<v_alive then
    update public.fa_time_impostor_games set updated_at=now() where id=v_game.id;
    return jsonb_build_object('complete',false,'submitted',true);
  end if;

  with tally as (
    select target_member_id,count(*)::integer votes
    from public.fa_time_impostor_elimination_votes v
    where v.game_id=v_game.id
      and v.round_no=v_game.round_no
      and v.stage=v_stage
    group by target_member_id
  )
  select max(votes) into v_max from tally;

  with tally as (
    select target_member_id,count(*)::integer votes
    from public.fa_time_impostor_elimination_votes v
    where v.game_id=v_game.id
      and v.round_no=v_game.round_no
      and v.stage=v_stage
    group by target_member_id
  )
  select array_agg(target_member_id order by target_member_id)
  into v_tied
  from tally
  where votes=v_max;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'voter_member_id',v.voter_member_id,
        'target_member_id',v.target_member_id
      )
      order by v.created_at
    ),
    '[]'::jsonb
  )
  into v_summary
  from public.fa_time_impostor_elimination_votes v
  where v.game_id=v_game.id
    and v.round_no=v_game.round_no
    and v.stage=v_stage;

  if cardinality(v_tied)=1 then
    perform private.fa_time_impostor_resolve_elimination(
      v_game.id,v_tied[1],v_summary
    );

    return jsonb_build_object(
      'complete',true,
      'eliminated_member_id',v_tied[1],
      'runoff',false
    );
  end if;

  if v_stage=1 then
    update public.fa_time_impostor_games
    set phase='runoff',
        vote_stage=2,
        runoff_candidates=v_tied,
        updated_at=now()
    where id=v_game.id;

    return jsonb_build_object(
      'complete',true,
      'runoff',true,
      'candidates',to_jsonb(v_tied)
    );
  end if;

  update public.fa_time_impostor_games
  set last_elimination=jsonb_build_object(
        'round',v_game.round_no,
        'member_id',null,
        'was_impostor',false,
        'reason','runoff_tie',
        'votes',v_summary
      ),
      updated_at=now()
  where id=v_game.id;

  perform private.fa_time_impostor_new_round(v_game.id);

  return jsonb_build_object(
    'complete',true,
    'runoff',false,
    'no_elimination',true,
    'reason','runoff_tie'
  );
end;
$function$;

create or replace function public.fa_time_impostor_state(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_me public.fa_room_members%rowtype;
  v_game public.fa_time_impostor_games%rowtype;
  v_round public.fa_time_impostor_rounds%rowtype;
  v_role text;
  v_eliminated boolean:=false;
  v_target_ms integer:=null;
  v_timer public.fa_time_impostor_timers%rowtype;
  v_members jsonb:='[]'::jsonb;
  v_results jsonb:='[]'::jsonb;
  v_my_decision text:=null;
  v_my_elimination uuid:=null;
  v_impostor jsonb:=null;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id;

  if not found or v_room.room_kind<>'time_impostor' then
    raise exception 'time impostor room not found';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=p_room_id
    and user_id=v_user
    and kicked_at is null;

  if not found then raise exception 'not a room member'; end if;

  select * into v_game
  from public.fa_time_impostor_games
  where room_id=p_room_id
  order by created_at desc
  limit 1;

  if not found then
    return jsonb_build_object(
      'room_status',v_room.status,
      'has_game',false,
      'role',case
        when v_room.host_user_id=v_user then 'admin'
        when v_me.is_spectator then 'spectator'
        else 'player'
      end
    );
  end if;

  select exists(
    select 1
    from public.fa_time_impostor_eliminations e
    where e.game_id=v_game.id
      and e.member_id=v_me.id
  )
  into v_eliminated;

  v_role:=case
    when v_room.host_user_id=v_user then 'admin'
    when v_me.is_spectator then 'spectator'
    when v_eliminated then 'eliminated'
    when v_me.id=v_game.impostor_member_id then 'impostor'
    else 'innocent'
  end;

  if v_game.active_round_id is not null then
    select * into v_round
    from public.fa_time_impostor_rounds
    where id=v_game.active_round_id;

    if v_role in ('admin','innocent','eliminated') or v_game.status='finished' then
      select target_ms into v_target_ms
      from private.fa_time_impostor_targets
      where round_id=v_round.id;
    end if;

    select * into v_timer
    from public.fa_time_impostor_timers t
    where t.round_id=v_round.id
      and t.member_id=v_me.id;

    if v_round.status in ('revealed','completed') then
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'member_id',t.member_id,
            'name',m.display_name,
            'elapsed_ms',t.elapsed_ms,
            'stopped',t.stopped_at is not null
          )
          order by t.elapsed_ms nulls last,m.joined_at
        ),
        '[]'::jsonb
      )
      into v_results
      from public.fa_time_impostor_timers t
      join public.fa_room_members m on m.id=t.member_id
      where t.round_id=v_round.id;
    end if;
  end if;

  if v_game.status='finished' or v_role='admin' then
    select jsonb_build_object('member_id',m.id,'name',m.display_name)
    into v_impostor
    from public.fa_room_members m
    where m.id=v_game.impostor_member_id;
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'member_id',m.id,
        'name',m.display_name,
        'is_admin',m.user_id=v_room.host_user_id,
        'is_spectator',m.is_spectator,
        'eliminated',exists(
          select 1 from public.fa_time_impostor_eliminations e
          where e.game_id=v_game.id and e.member_id=m.id
        ),
        'alive',(
          not m.is_spectator
          and m.kicked_at is null
          and not exists(
            select 1 from public.fa_time_impostor_eliminations e
            where e.game_id=v_game.id and e.member_id=m.id
          )
        )
      )
      order by m.joined_at
    ),
    '[]'::jsonb
  )
  into v_members
  from public.fa_room_members m
  where m.room_id=p_room_id
    and m.kicked_at is null;

  select d.choice into v_my_decision
  from public.fa_time_impostor_decision_votes d
  where d.game_id=v_game.id
    and d.round_no=v_game.round_no
    and d.member_id=v_me.id;

  select e.target_member_id into v_my_elimination
  from public.fa_time_impostor_elimination_votes e
  where e.game_id=v_game.id
    and e.round_no=v_game.round_no
    and e.stage=case when v_game.phase='runoff' then 2 else 1 end
    and e.voter_member_id=v_me.id;

  return jsonb_build_object(
    'room_status',v_room.status,
    'has_game',true,
    'game_id',v_game.id,
    'status',v_game.status,
    'phase',v_game.phase,
    'round_no',v_game.round_no,
    'role',v_role,
    'me_member_id',v_me.id,
    'winner_side',v_game.winner_side,
    'impostor',v_impostor,
    'target_seconds',case
      when v_target_ms is null then null
      else round((v_target_ms::numeric/1000.0),3)
    end,
    'active_round_id',v_game.active_round_id,
    'timer_state',case
      when v_timer.id is null then null
      else case
        when v_timer.stopped_at is not null then 'stopped'
        when v_timer.started_at is not null then 'running'
        else 'ready'
      end
    end,
    'results',v_results,
    'my_decision_vote',v_my_decision,
    'my_elimination_vote',v_my_elimination,
    'last_decision',v_game.last_decision,
    'last_elimination',v_game.last_elimination,
    'runoff_candidates',coalesce(to_jsonb(v_game.runoff_candidates),'[]'::jsonb),
    'members',v_members
  );
end;
$function$;

create or replace function public.fa_time_impostor_replay(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only admin can restart'; end if;
  if v_room.room_kind<>'time_impostor' then raise exception 'not a time impostor room'; end if;
  if v_room.status<>'finished' then raise exception 'game is not finished'; end if;

  update public.fa_room_members
  set ready=false,
      last_seen_at=case when user_id=v_user then now() else last_seen_at end
  where room_id=p_room_id;

  update public.fa_rooms
  set status='lobby'
  where id=p_room_id;

  return jsonb_build_object('restarted',true);
end;
$function$;

revoke all on function public.fa_create_time_impostor_room(text,boolean,text) from public,anon;
revoke all on function public.fa_begin_time_impostor_mode(uuid) from public,anon;
revoke all on function public.fa_time_impostor_start_round(uuid,numeric) from public,anon;
revoke all on function public.fa_time_impostor_start_timer(uuid) from public,anon;
revoke all on function public.fa_time_impostor_stop_timer(uuid) from public,anon;
revoke all on function public.fa_time_impostor_open_decision(uuid) from public,anon;
revoke all on function public.fa_time_impostor_decide_round(uuid,text) from public,anon;
revoke all on function public.fa_time_impostor_vote_elimination(uuid,uuid) from public,anon;
revoke all on function public.fa_time_impostor_state(uuid) from public,anon;
revoke all on function public.fa_time_impostor_replay(uuid) from public,anon;

grant execute on function public.fa_create_time_impostor_room(text,boolean,text) to authenticated;
grant execute on function public.fa_begin_time_impostor_mode(uuid) to authenticated;
grant execute on function public.fa_time_impostor_start_round(uuid,numeric) to authenticated;
grant execute on function public.fa_time_impostor_start_timer(uuid) to authenticated;
grant execute on function public.fa_time_impostor_stop_timer(uuid) to authenticated;
grant execute on function public.fa_time_impostor_open_decision(uuid) to authenticated;
grant execute on function public.fa_time_impostor_decide_round(uuid,text) to authenticated;
grant execute on function public.fa_time_impostor_vote_elimination(uuid,uuid) to authenticated;
grant execute on function public.fa_time_impostor_state(uuid) to authenticated;
grant execute on function public.fa_time_impostor_replay(uuid) to authenticated;
