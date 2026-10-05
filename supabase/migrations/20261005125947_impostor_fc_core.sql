
alter table public.fa_rooms drop constraint if exists fa_rooms_room_kind_check;
alter table public.fa_rooms
  add constraint fa_rooms_room_kind_check
  check (room_kind in ('auction','tournament','cases','impostor'));

create table if not exists public.fa_impostor_games (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  secret_catalog_id text not null references public.fa_catalog_players(id),
  hint text not null,
  impostor_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  status text not null default 'playing'
    check (status in ('playing','finished')),
  phase text not null default 'question'
    check (phase in ('question','answering','rating','decision','elimination','runoff','finished')),
  round_no integer not null default 1 check (round_no > 0),
  current_questioner_member_id uuid references public.fa_room_members(id) on delete set null,
  active_question_id uuid,
  vote_stage integer not null default 1 check (vote_stage in (1,2)),
  runoff_candidates uuid[],
  last_decision jsonb,
  last_elimination jsonb,
  winner_side text check (winner_side is null or winner_side in ('innocents','impostor')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  finished_at timestamptz
);

create index if not exists fa_impostor_games_room_created_idx
  on public.fa_impostor_games(room_id,created_at desc);

create table if not exists public.fa_impostor_questions (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_impostor_games(id) on delete cascade,
  round_no integer not null check (round_no > 0),
  questioner_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  question_text text not null,
  status text not null default 'answering'
    check (status in ('answering','rating','completed')),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique(game_id,round_no,questioner_member_id)
);

create index if not exists fa_impostor_questions_game_round_idx
  on public.fa_impostor_questions(game_id,round_no,created_at);

alter table public.fa_impostor_games
  drop constraint if exists fa_impostor_games_active_question_fkey;
alter table public.fa_impostor_games
  add constraint fa_impostor_games_active_question_fkey
  foreign key(active_question_id)
  references public.fa_impostor_questions(id)
  on delete set null;

create table if not exists public.fa_impostor_answers (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  question_id uuid not null references public.fa_impostor_questions(id) on delete cascade,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  answer_text text not null,
  created_at timestamptz not null default now(),
  unique(question_id,member_id)
);

create index if not exists fa_impostor_answers_question_idx
  on public.fa_impostor_answers(question_id);

create table if not exists public.fa_impostor_ratings (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  question_id uuid not null references public.fa_impostor_questions(id) on delete cascade,
  rater_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  target_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  rating text not null check (rating in ('good','suspicious')),
  created_at timestamptz not null default now(),
  unique(question_id,rater_member_id,target_member_id),
  check (rater_member_id<>target_member_id)
);

create index if not exists fa_impostor_ratings_question_idx
  on public.fa_impostor_ratings(question_id);

create table if not exists public.fa_impostor_decision_votes (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_impostor_games(id) on delete cascade,
  round_no integer not null,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  choice text not null check (choice in ('vote','continue')),
  created_at timestamptz not null default now(),
  unique(game_id,round_no,member_id)
);

create index if not exists fa_impostor_decision_votes_game_round_idx
  on public.fa_impostor_decision_votes(game_id,round_no);

create table if not exists public.fa_impostor_elimination_votes (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_impostor_games(id) on delete cascade,
  round_no integer not null,
  stage integer not null check (stage in (1,2)),
  voter_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  target_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(game_id,round_no,stage,voter_member_id),
  check (voter_member_id<>target_member_id)
);

create index if not exists fa_impostor_elimination_votes_game_round_idx
  on public.fa_impostor_elimination_votes(game_id,round_no,stage);

create table if not exists public.fa_impostor_eliminations (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  game_id uuid not null references public.fa_impostor_games(id) on delete cascade,
  round_no integer not null,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  was_impostor boolean not null,
  created_at timestamptz not null default now(),
  unique(game_id,member_id)
);

create index if not exists fa_impostor_eliminations_game_idx
  on public.fa_impostor_eliminations(game_id,created_at);

alter table public.fa_impostor_games enable row level security;
alter table public.fa_impostor_questions enable row level security;
alter table public.fa_impostor_answers enable row level security;
alter table public.fa_impostor_ratings enable row level security;
alter table public.fa_impostor_decision_votes enable row level security;
alter table public.fa_impostor_elimination_votes enable row level security;
alter table public.fa_impostor_eliminations enable row level security;

revoke all on public.fa_impostor_games from public,anon,authenticated;
revoke all on public.fa_impostor_questions from public,anon,authenticated;
revoke all on public.fa_impostor_answers from public,anon,authenticated;
revoke all on public.fa_impostor_ratings from public,anon,authenticated;
revoke all on public.fa_impostor_decision_votes from public,anon,authenticated;
revoke all on public.fa_impostor_elimination_votes from public,anon,authenticated;
revoke all on public.fa_impostor_eliminations from public,anon,authenticated;

create or replace function private.fa_impostor_member_alive(
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
    from public.fa_impostor_games g
    join public.fa_room_members m
      on m.room_id=g.room_id
     and m.id=p_member_id
    where g.id=p_game_id
      and not m.is_spectator
      and m.kicked_at is null
      and not exists(
        select 1
        from public.fa_impostor_eliminations e
        where e.game_id=g.id
          and e.member_id=m.id
      )
  );
$function$;

create or replace function private.fa_impostor_advance_question(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_game public.fa_impostor_games%rowtype;
  v_next uuid;
begin
  select * into v_game
  from public.fa_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing' then
    return;
  end if;

  select m.id into v_next
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_impostor_eliminations e
      where e.game_id=v_game.id
        and e.member_id=m.id
    )
    and not exists(
      select 1
      from public.fa_impostor_questions q
      where q.game_id=v_game.id
        and q.round_no=v_game.round_no
        and q.questioner_member_id=m.id
    )
  order by m.joined_at
  limit 1;

  if v_next is null then
    update public.fa_impostor_games
    set phase='decision',
        current_questioner_member_id=null,
        active_question_id=null,
        updated_at=now()
    where id=v_game.id;
  else
    update public.fa_impostor_games
    set phase='question',
        current_questioner_member_id=v_next,
        active_question_id=null,
        updated_at=now()
    where id=v_game.id;
  end if;
end;
$function$;

create or replace function private.fa_impostor_begin_next_round(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path=''
as $function$
begin
  update public.fa_impostor_games
  set round_no=round_no+1,
      phase='question',
      current_questioner_member_id=null,
      active_question_id=null,
      vote_stage=1,
      runoff_candidates=null,
      updated_at=now()
  where id=p_game_id
    and status='playing';

  perform private.fa_impostor_advance_question(p_game_id);
end;
$function$;

create or replace function private.fa_impostor_resolve_elimination(
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
  v_game public.fa_impostor_games%rowtype;
  v_was_impostor boolean;
  v_alive integer;
begin
  select * into v_game
  from public.fa_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing' then
    return;
  end if;

  if not private.fa_impostor_member_alive(v_game.id,p_member_id) then
    raise exception 'target is not alive';
  end if;

  v_was_impostor:=p_member_id=v_game.impostor_member_id;

  insert into public.fa_impostor_eliminations(
    room_id,game_id,round_no,member_id,was_impostor
  )
  values(
    v_game.room_id,v_game.id,v_game.round_no,p_member_id,v_was_impostor
  )
  on conflict(game_id,member_id) do nothing;

  update public.fa_impostor_games
  set last_elimination=jsonb_build_object(
        'round',v_game.round_no,
        'member_id',p_member_id,
        'was_impostor',v_was_impostor,
        'votes',p_vote_summary
      ),
      updated_at=now()
  where id=v_game.id;

  if v_was_impostor then
    update public.fa_impostor_games
    set status='finished',
        phase='finished',
        winner_side='innocents',
        current_questioner_member_id=null,
        active_question_id=null,
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
      from public.fa_impostor_eliminations e
      where e.game_id=v_game.id
        and e.member_id=m.id
    );

  if v_alive<=2 then
    update public.fa_impostor_games
    set status='finished',
        phase='finished',
        winner_side='impostor',
        current_questioner_member_id=null,
        active_question_id=null,
        finished_at=now(),
        updated_at=now()
    where id=v_game.id;

    update public.fa_rooms
    set status='finished'
    where id=v_game.room_id;

    return;
  end if;

  perform private.fa_impostor_begin_next_round(v_game.id);
end;
$function$;

create or replace function public.fa_create_impostor_room(
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
  set room_kind='impostor',
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

create or replace function public.fa_begin_impostor_mode(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_count integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only host can start'; end if;
  if v_room.room_kind<>'impostor' then raise exception 'not an impostor room'; end if;
  if v_room.status<>'lobby' then return to_jsonb(v_room); end if;

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

  delete from public.fa_impostor_games
  where room_id=p_room_id
    and status='playing';

  update public.fa_rooms
  set status='auction'
  where id=p_room_id
  returning * into v_room;

  return to_jsonb(v_room);
end;
$function$;

create or replace function public.fa_start_impostor_game(
  p_room_id uuid,
  p_catalog_id text,
  p_hint text
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_impostor uuid;
  v_first uuid;
  v_game public.fa_impostor_games%rowtype;
  v_hint text:=trim(coalesce(p_hint,''));
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only host can configure the game'; end if;
  if v_room.room_kind<>'impostor' then raise exception 'not an impostor room'; end if;
  if v_room.status<>'auction' then raise exception 'impostor mode is not waiting for setup'; end if;

  if char_length(v_hint)<2 or char_length(v_hint)>160 then
    raise exception 'hint must have between 2 and 160 characters';
  end if;

  if not exists(
    select 1
    from public.fa_catalog_players c
    where c.id=p_catalog_id
      and c.enabled
      and private.fa_catalog_allowed_for_room(p_room_id,c.id)
  ) then
    raise exception 'secret player is not eligible for this room';
  end if;

  if exists(
    select 1
    from public.fa_impostor_games g
    where g.room_id=p_room_id
      and g.status='playing'
  ) then
    raise exception 'game already started';
  end if;

  select m.id into v_impostor
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by random()
  limit 1;

  if v_impostor is null then raise exception 'no active players'; end if;

  select m.id into v_first
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by m.joined_at
  limit 1;

  insert into public.fa_impostor_games(
    room_id,
    secret_catalog_id,
    hint,
    impostor_member_id,
    status,
    phase,
    round_no,
    current_questioner_member_id
  )
  values(
    p_room_id,
    p_catalog_id,
    v_hint,
    v_impostor,
    'playing',
    'question',
    1,
    v_first
  )
  returning * into v_game;

  return jsonb_build_object(
    'id',v_game.id,
    'status',v_game.status,
    'phase',v_game.phase,
    'round_no',v_game.round_no
  );
end;
$function$;

create or replace function public.fa_impostor_submit_question(
  p_game_id uuid,
  p_question text
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_game public.fa_impostor_games%rowtype;
  v_me public.fa_room_members%rowtype;
  v_question public.fa_impostor_questions%rowtype;
  v_text text:=trim(coalesce(p_question,''));
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if char_length(v_text)<2 or char_length(v_text)>220 then
    raise exception 'question must have between 2 and 220 characters';
  end if;

  select * into v_game
  from public.fa_impostor_games
  where id=p_game_id
  for update;

  if not found or v_game.status<>'playing' then raise exception 'game not active'; end if;
  if v_game.phase<>'question' then raise exception 'not question phase'; end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_game.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found then raise exception 'not an active player'; end if;
  if not private.fa_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'eliminated players cannot ask';
  end if;
  if v_game.current_questioner_member_id<>v_me.id then
    raise exception 'it is not your turn to ask';
  end if;

  insert into public.fa_impostor_questions(
    room_id,game_id,round_no,questioner_member_id,question_text,status
  )
  values(
    v_game.room_id,v_game.id,v_game.round_no,v_me.id,v_text,'answering'
  )
  returning * into v_question;

  update public.fa_impostor_games
  set phase='answering',
      active_question_id=v_question.id,
      updated_at=now()
  where id=v_game.id;

  return to_jsonb(v_question);
end;
$function$;

create or replace function public.fa_impostor_submit_answer(
  p_question_id uuid,
  p_answer text
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_question public.fa_impostor_questions%rowtype;
  v_game public.fa_impostor_games%rowtype;
  v_me public.fa_room_members%rowtype;
  v_answer public.fa_impostor_answers%rowtype;
  v_text text:=trim(coalesce(p_answer,''));
  v_alive integer;
  v_answered integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if char_length(v_text)<1 or char_length(v_text)>220 then
    raise exception 'answer must have between 1 and 220 characters';
  end if;

  select * into v_question
  from public.fa_impostor_questions
  where id=p_question_id
  for update;

  if not found or v_question.status<>'answering' then
    raise exception 'question is not accepting answers';
  end if;

  select * into v_game
  from public.fa_impostor_games
  where id=v_question.game_id
  for update;

  if v_game.status<>'playing' or v_game.phase<>'answering'
     or v_game.active_question_id<>v_question.id
  then
    raise exception 'question is not active';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_game.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found or not private.fa_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  insert into public.fa_impostor_answers(room_id,question_id,member_id,answer_text)
  values(v_game.room_id,v_question.id,v_me.id,v_text)
  on conflict(question_id,member_id) do update set
    answer_text=excluded.answer_text
  returning * into v_answer;

  select count(*) into v_alive
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_impostor_eliminations e
      where e.game_id=v_game.id
        and e.member_id=m.id
    );

  select count(*) into v_answered
  from public.fa_impostor_answers a
  where a.question_id=v_question.id;

  if v_answered>=v_alive then
    update public.fa_impostor_questions
    set status='rating'
    where id=v_question.id;

    update public.fa_impostor_games
    set phase='rating',updated_at=now()
    where id=v_game.id;
  else
    update public.fa_impostor_games
    set updated_at=now()
    where id=v_game.id;
  end if;

  return to_jsonb(v_answer);
end;
$function$;

create or replace function public.fa_impostor_rate_answer(
  p_question_id uuid,
  p_target_member_id uuid,
  p_rating text
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_question public.fa_impostor_questions%rowtype;
  v_game public.fa_impostor_games%rowtype;
  v_me public.fa_room_members%rowtype;
  v_rating public.fa_impostor_ratings%rowtype;
  v_alive integer;
  v_expected integer;
  v_total integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if p_rating not in ('good','suspicious') then raise exception 'invalid rating'; end if;

  select * into v_question
  from public.fa_impostor_questions
  where id=p_question_id
  for update;

  if not found or v_question.status<>'rating' then
    raise exception 'question is not in rating phase';
  end if;

  select * into v_game
  from public.fa_impostor_games
  where id=v_question.game_id
  for update;

  if v_game.status<>'playing' or v_game.phase<>'rating'
     or v_game.active_question_id<>v_question.id
  then
    raise exception 'rating phase is not active';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_game.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found or not private.fa_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  if p_target_member_id=v_me.id then
    raise exception 'you cannot rate your own answer';
  end if;

  if not private.fa_impostor_member_alive(v_game.id,p_target_member_id) then
    raise exception 'target is not active';
  end if;

  if not exists(
    select 1
    from public.fa_impostor_answers a
    where a.question_id=v_question.id
      and a.member_id=p_target_member_id
  ) then
    raise exception 'target has no answer';
  end if;

  insert into public.fa_impostor_ratings(
    room_id,question_id,rater_member_id,target_member_id,rating
  )
  values(
    v_game.room_id,v_question.id,v_me.id,p_target_member_id,p_rating
  )
  on conflict(question_id,rater_member_id,target_member_id) do update set
    rating=excluded.rating
  returning * into v_rating;

  select count(*) into v_alive
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_impostor_eliminations e
      where e.game_id=v_game.id
        and e.member_id=m.id
    );

  v_expected:=v_alive*(v_alive-1);

  select count(*) into v_total
  from public.fa_impostor_ratings r
  where r.question_id=v_question.id;

  if v_total>=v_expected then
    update public.fa_impostor_questions
    set status='completed',completed_at=now()
    where id=v_question.id;

    perform private.fa_impostor_advance_question(v_game.id);
  else
    update public.fa_impostor_games
    set updated_at=now()
    where id=v_game.id;
  end if;

  return to_jsonb(v_rating);
end;
$function$;

create or replace function public.fa_impostor_decide_round(
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
  v_game public.fa_impostor_games%rowtype;
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
  from public.fa_impostor_games
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

  if not found or not private.fa_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  insert into public.fa_impostor_decision_votes(
    room_id,game_id,round_no,member_id,choice
  )
  values(
    v_game.room_id,v_game.id,v_game.round_no,v_me.id,p_choice
  )
  on conflict(game_id,round_no,member_id) do update set
    choice=excluded.choice;

  select count(*) into v_alive
  from public.fa_room_members m
  where m.room_id=v_game.room_id
    and not m.is_spectator
    and m.kicked_at is null
    and not exists(
      select 1
      from public.fa_impostor_eliminations e
      where e.game_id=v_game.id and e.member_id=m.id
    );

  select count(*) into v_total
  from public.fa_impostor_decision_votes d
  where d.game_id=v_game.id and d.round_no=v_game.round_no;

  if v_total<v_alive then
    update public.fa_impostor_games set updated_at=now() where id=v_game.id;
    return jsonb_build_object('complete',false,'submitted',true);
  end if;

  select
    count(*) filter(where d.choice='vote'),
    count(*) filter(where d.choice='continue')
  into v_vote,v_continue
  from public.fa_impostor_decision_votes d
  where d.game_id=v_game.id and d.round_no=v_game.round_no;

  v_result:=jsonb_build_object(
    'round',v_game.round_no,
    'vote',v_vote,
    'continue',v_continue,
    'result',case when v_vote>v_continue then 'vote' else 'continue' end,
    'tie',v_vote=v_continue
  );

  update public.fa_impostor_games
  set last_decision=v_result,
      updated_at=now()
  where id=v_game.id;

  if v_vote>v_continue then
    update public.fa_impostor_games
    set phase='elimination',
        vote_stage=1,
        runoff_candidates=null,
        updated_at=now()
    where id=v_game.id;
  else
    perform private.fa_impostor_begin_next_round(v_game.id);
  end if;

  return v_result || jsonb_build_object('complete',true);
end;
$function$;

create or replace function public.fa_impostor_vote_elimination(
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
  v_game public.fa_impostor_games%rowtype;
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
  from public.fa_impostor_games
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

  if not found or not private.fa_impostor_member_alive(v_game.id,v_me.id) then
    raise exception 'not an active player';
  end if;

  if p_target_member_id=v_me.id then
    raise exception 'you cannot vote for yourself';
  end if;

  if not private.fa_impostor_member_alive(v_game.id,p_target_member_id) then
    raise exception 'target is not active';
  end if;

  v_stage:=case when v_game.phase='runoff' then 2 else 1 end;

  if v_stage=2 and not (p_target_member_id=any(coalesce(v_game.runoff_candidates,array[]::uuid[]))) then
    raise exception 'target is not in runoff';
  end if;

  insert into public.fa_impostor_elimination_votes(
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
      from public.fa_impostor_eliminations e
      where e.game_id=v_game.id and e.member_id=m.id
    );

  select count(*) into v_total
  from public.fa_impostor_elimination_votes v
  where v.game_id=v_game.id
    and v.round_no=v_game.round_no
    and v.stage=v_stage;

  if v_total<v_alive then
    update public.fa_impostor_games set updated_at=now() where id=v_game.id;
    return jsonb_build_object('complete',false,'submitted',true);
  end if;

  with tally as (
    select target_member_id,count(*)::integer votes
    from public.fa_impostor_elimination_votes v
    where v.game_id=v_game.id
      and v.round_no=v_game.round_no
      and v.stage=v_stage
    group by target_member_id
  )
  select max(votes) into v_max from tally;

  with tally as (
    select target_member_id,count(*)::integer votes
    from public.fa_impostor_elimination_votes v
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
  from public.fa_impostor_elimination_votes v
  where v.game_id=v_game.id
    and v.round_no=v_game.round_no
    and v.stage=v_stage;

  if cardinality(v_tied)=1 then
    perform private.fa_impostor_resolve_elimination(
      v_game.id,
      v_tied[1],
      v_summary
    );

    return jsonb_build_object(
      'complete',true,
      'eliminated_member_id',v_tied[1],
      'runoff',false
    );
  end if;

  if v_stage=1 then
    update public.fa_impostor_games
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

  update public.fa_impostor_games
  set last_elimination=jsonb_build_object(
        'round',v_game.round_no,
        'member_id',null,
        'was_impostor',false,
        'reason','runoff_tie',
        'votes',v_summary
      ),
      updated_at=now()
  where id=v_game.id;

  perform private.fa_impostor_begin_next_round(v_game.id);

  return jsonb_build_object(
    'complete',true,
    'runoff',false,
    'no_elimination',true,
    'reason','runoff_tie'
  );
end;
$function$;

create or replace function public.fa_impostor_state(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_me public.fa_room_members%rowtype;
  v_game public.fa_impostor_games%rowtype;
  v_question public.fa_impostor_questions%rowtype;
  v_role text;
  v_eliminated boolean:=false;
  v_show_secret boolean:=false;
  v_show_impostor boolean:=false;
  v_secret jsonb:=null;
  v_hint text:=null;
  v_impostor jsonb:=null;
  v_my_answer jsonb:=null;
  v_answers jsonb:='[]'::jsonb;
  v_ratings jsonb:='[]'::jsonb;
  v_history jsonb:='[]'::jsonb;
  v_members jsonb:='[]'::jsonb;
  v_decision_vote text:=null;
  v_elimination_vote uuid:=null;
  v_my_ratings jsonb:='[]'::jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id;

  if not found or v_room.room_kind<>'impostor' then
    raise exception 'impostor room not found';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=p_room_id
    and user_id=v_user
    and kicked_at is null;

  if not found then raise exception 'not a room member'; end if;

  select * into v_game
  from public.fa_impostor_games
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
    from public.fa_impostor_eliminations e
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

  v_show_secret:=v_role in ('admin','innocent','eliminated')
    or v_game.status='finished';
  v_show_impostor:=v_role='admin' or v_game.status='finished';

  if v_show_secret then
    select jsonb_build_object(
      'id',c.id,
      'name',c.name,
      'club',c.club,
      'league',c.league,
      'nationality',c.nationality,
      'primary_position',c.primary_position,
      'overall',c.overall,
      'player_type',c.player_type,
      'image_url',c.image_url
    )
    into v_secret
    from public.fa_catalog_players c
    where c.id=v_game.secret_catalog_id;
  end if;

  if v_role in ('admin','impostor') or v_game.status='finished' then
    v_hint:=v_game.hint;
  end if;

  if v_show_impostor then
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
          select 1 from public.fa_impostor_eliminations e
          where e.game_id=v_game.id and e.member_id=m.id
        ),
        'alive',(
          not m.is_spectator
          and m.kicked_at is null
          and not exists(
            select 1 from public.fa_impostor_eliminations e
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

  if v_game.active_question_id is not null then
    select * into v_question
    from public.fa_impostor_questions
    where id=v_game.active_question_id;

    select to_jsonb(a) into v_my_answer
    from public.fa_impostor_answers a
    where a.question_id=v_question.id
      and a.member_id=v_me.id;

    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'target_member_id',r.target_member_id,
          'rating',r.rating
        )
      ),
      '[]'::jsonb
    )
    into v_my_ratings
    from public.fa_impostor_ratings r
    where r.question_id=v_question.id
      and r.rater_member_id=v_me.id;

    if v_question.status in ('rating','completed') then
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'member_id',a.member_id,
            'name',m.display_name,
            'answer',a.answer_text
          )
          order by m.joined_at
        ),
        '[]'::jsonb
      )
      into v_answers
      from public.fa_impostor_answers a
      join public.fa_room_members m on m.id=a.member_id
      where a.question_id=v_question.id;
    end if;

    if v_question.status='completed' then
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'rater_member_id',r.rater_member_id,
            'rater_name',rm.display_name,
            'target_member_id',r.target_member_id,
            'target_name',tm.display_name,
            'rating',r.rating
          )
          order by r.created_at
        ),
        '[]'::jsonb
      )
      into v_ratings
      from public.fa_impostor_ratings r
      join public.fa_room_members rm on rm.id=r.rater_member_id
      join public.fa_room_members tm on tm.id=r.target_member_id
      where r.question_id=v_question.id;
    end if;
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id',q.id,
        'round_no',q.round_no,
        'questioner_member_id',q.questioner_member_id,
        'questioner_name',qm.display_name,
        'question',q.question_text,
        'answers',(
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'member_id',a.member_id,
                'name',am.display_name,
                'answer',a.answer_text
              )
              order by am.joined_at
            ),
            '[]'::jsonb
          )
          from public.fa_impostor_answers a
          join public.fa_room_members am on am.id=a.member_id
          where a.question_id=q.id
        ),
        'ratings',(
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'rater_member_id',r.rater_member_id,
                'rater_name',rm.display_name,
                'target_member_id',r.target_member_id,
                'target_name',tm.display_name,
                'rating',r.rating
              )
              order by r.created_at
            ),
            '[]'::jsonb
          )
          from public.fa_impostor_ratings r
          join public.fa_room_members rm on rm.id=r.rater_member_id
          join public.fa_room_members tm on tm.id=r.target_member_id
          where r.question_id=q.id
        )
      )
      order by q.round_no,q.created_at
    ),
    '[]'::jsonb
  )
  into v_history
  from public.fa_impostor_questions q
  join public.fa_room_members qm on qm.id=q.questioner_member_id
  where q.game_id=v_game.id
    and q.status='completed';

  select d.choice into v_decision_vote
  from public.fa_impostor_decision_votes d
  where d.game_id=v_game.id
    and d.round_no=v_game.round_no
    and d.member_id=v_me.id;

  select e.target_member_id into v_elimination_vote
  from public.fa_impostor_elimination_votes e
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
    'secret_player',v_secret,
    'hint',v_hint,
    'impostor',v_impostor,
    'winner_side',v_game.winner_side,
    'current_questioner_member_id',v_game.current_questioner_member_id,
    'active_question',case
      when v_question.id is null then null
      else jsonb_build_object(
        'id',v_question.id,
        'questioner_member_id',v_question.questioner_member_id,
        'questioner_name',(
          select m.display_name from public.fa_room_members m
          where m.id=v_question.questioner_member_id
        ),
        'question',v_question.question_text,
        'status',v_question.status,
        'answers',v_answers,
        'ratings',v_ratings
      )
    end,
    'my_answer',v_my_answer,
    'my_ratings',v_my_ratings,
    'my_decision_vote',v_decision_vote,
    'my_elimination_vote',v_elimination_vote,
    'last_decision',v_game.last_decision,
    'last_elimination',v_game.last_elimination,
    'runoff_candidates',coalesce(to_jsonb(v_game.runoff_candidates),'[]'::jsonb),
    'members',v_members,
    'history',v_history
  );
end;
$function$;

revoke all on function public.fa_create_impostor_room(text,boolean,text) from public,anon;
revoke all on function public.fa_begin_impostor_mode(uuid) from public,anon;
revoke all on function public.fa_start_impostor_game(uuid,text,text) from public,anon;
revoke all on function public.fa_impostor_submit_question(uuid,text) from public,anon;
revoke all on function public.fa_impostor_submit_answer(uuid,text) from public,anon;
revoke all on function public.fa_impostor_rate_answer(uuid,uuid,text) from public,anon;
revoke all on function public.fa_impostor_decide_round(uuid,text) from public,anon;
revoke all on function public.fa_impostor_vote_elimination(uuid,uuid) from public,anon;
revoke all on function public.fa_impostor_state(uuid) from public,anon;

grant execute on function public.fa_create_impostor_room(text,boolean,text) to authenticated;
grant execute on function public.fa_begin_impostor_mode(uuid) to authenticated;
grant execute on function public.fa_start_impostor_game(uuid,text,text) to authenticated;
grant execute on function public.fa_impostor_submit_question(uuid,text) to authenticated;
grant execute on function public.fa_impostor_submit_answer(uuid,text) to authenticated;
grant execute on function public.fa_impostor_rate_answer(uuid,uuid,text) to authenticated;
grant execute on function public.fa_impostor_decide_round(uuid,text) to authenticated;
grant execute on function public.fa_impostor_vote_elimination(uuid,uuid) to authenticated;
grant execute on function public.fa_impostor_state(uuid) to authenticated;
