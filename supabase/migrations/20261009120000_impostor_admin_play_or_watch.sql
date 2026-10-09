
alter table public.fa_impostor_games
  add column if not exists secret_custom jsonb;

alter table public.fa_impostor_games
  alter column secret_catalog_id drop not null;

create or replace function public.fa_create_impostor_room(
  p_display_name text,
  p_spectators_allowed boolean,
  p_password text,
  p_admin_plays boolean
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
  set is_spectator=not coalesce(p_admin_plays,false),
      ready=false,
      balance=0
  where id=v.member_id;

  return query select v.room_id,v.room_code,v.member_id;
end;
$function$;

drop function if exists public.fa_create_impostor_room(text,boolean,text);

create function public.fa_create_impostor_room(
  p_display_name text,
  p_spectators_allowed boolean default true,
  p_password text default null
)
returns table(room_id uuid,room_code text,member_id uuid)
language plpgsql
security definer
set search_path=''
as $function$
begin
  return query
  select *
  from public.fa_create_impostor_room(
    p_display_name,
    p_spectators_allowed,
    p_password,
    false
  );
end;
$function$;

drop function if exists public.fa_start_impostor_game(uuid,text[]);

create or replace function public.fa_start_impostor_game(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_host_member public.fa_room_members%rowtype;
  v_impostor uuid;
  v_first uuid;
  v_secret text;
  v_hint text;
  v_game public.fa_impostor_games%rowtype;
  v_player_count integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only host can start'; end if;
  if v_room.room_kind<>'impostor' then raise exception 'not an impostor room'; end if;
  if v_room.status<>'auction' then raise exception 'impostor mode is not waiting for setup'; end if;

  select * into v_host_member
  from public.fa_room_members
  where room_id=p_room_id and user_id=v_user and kicked_at is null
  for update;

  if not found or v_host_member.is_spectator then
    raise exception 'choose play mode to start as a player';
  end if;

  select count(*) into v_player_count
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds';

  if v_player_count<4 then raise exception 'at least four active players are required'; end if;

  if exists(
    select 1 from public.fa_room_members m
    where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
      and m.last_seen_at>=now()-interval '30 seconds' and not m.ready
  ) then
    raise exception 'all active players must be ready';
  end if;

  if exists(
    select 1 from public.fa_impostor_games g
    where g.room_id=p_room_id and g.status='playing'
  ) then
    raise exception 'game already started';
  end if;

  select c.id into v_secret
  from public.fa_catalog_players c
  where c.enabled
    and coalesce(c.metadata->>'source','')<>'impostor_custom'
  order by random()
  limit 1;

  if v_secret is null then raise exception 'no eligible secret player found'; end if;

  v_hint:=private.fa_impostor_generate_hint(v_secret);

  select m.id into v_impostor
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by random()
  limit 1;

  select m.id into v_first
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by m.joined_at
  limit 1;

  insert into public.fa_impostor_games(
    room_id,secret_catalog_id,secret_custom,hint,impostor_member_id,allowed_leagues,
    status,phase,round_no,current_questioner_member_id
  )
  values(
    p_room_id,v_secret,null,v_hint,v_impostor,'{}'::text[],
    'playing','question',1,v_first
  )
  returning * into v_game;

  return jsonb_build_object(
    'id',v_game.id,'status',v_game.status,'phase',v_game.phase,'round_no',v_game.round_no
  );
end;
$function$;

create or replace function public.fa_start_impostor_hosted_game(
  p_room_id uuid,
  p_secret_catalog_id text,
  p_custom_player jsonb,
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
  v_host_member public.fa_room_members%rowtype;
  v_impostor uuid;
  v_first uuid;
  v_game public.fa_impostor_games%rowtype;
  v_player_count integer;
  v_hint text:=trim(coalesce(p_hint,''));
  v_name text;
  v_club text;
  v_nationality text;
  v_secret_custom jsonb:=null;
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

  select * into v_host_member
  from public.fa_room_members
  where room_id=p_room_id and user_id=v_user and kicked_at is null
  for update;

  if not found or not v_host_member.is_spectator then
    raise exception 'this setup is only for a watching administrator';
  end if;

  if (p_secret_catalog_id is null)=(p_custom_player is null) then
    raise exception 'choose either a catalog player or a custom player';
  end if;

  if char_length(v_hint)<2 or char_length(v_hint)>160 then
    raise exception 'hint must have between 2 and 160 characters';
  end if;

  if p_secret_catalog_id is not null then
    if not exists(
      select 1
      from public.fa_catalog_players c
      where c.id=p_secret_catalog_id
        and c.enabled
        and private.fa_catalog_allowed_for_room(p_room_id,c.id)
        and coalesce(c.metadata->>'source','')<>'impostor_custom'
    ) then
      raise exception 'secret player is not eligible for this room';
    end if;
  else
    if jsonb_typeof(p_custom_player)<>'object' then
      raise exception 'custom player must be an object';
    end if;

    v_name:=trim(coalesce(p_custom_player->>'name',''));
    v_club:=nullif(trim(coalesce(p_custom_player->>'club','')),'');
    v_nationality:=nullif(trim(coalesce(p_custom_player->>'nationality','')),'');

    if char_length(v_name)<2 or char_length(v_name)>100 then
      raise exception 'custom player name must have between 2 and 100 characters';
    end if;

    if char_length(coalesce(v_club,''))>100 or char_length(coalesce(v_nationality,''))>100 then
      raise exception 'custom player details are too long';
    end if;

    v_secret_custom:=jsonb_build_object(
      'id','custom',
      'name',v_name,
      'club',v_club,
      'league',null,
      'nationality',v_nationality,
      'primary_position','',
      'overall',0,
      'player_type','CUSTOM',
      'image_url',null,
      'is_custom',true
    );
  end if;

  select count(*) into v_player_count
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds';

  if v_player_count<4 then raise exception 'at least four active players are required'; end if;

  if exists(
    select 1 from public.fa_room_members m
    where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
      and m.last_seen_at>=now()-interval '30 seconds' and not m.ready
  ) then
    raise exception 'all active players must be ready';
  end if;

  if exists(
    select 1 from public.fa_impostor_games g
    where g.room_id=p_room_id and g.status='playing'
  ) then
    raise exception 'game already started';
  end if;

  select m.id into v_impostor
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by random()
  limit 1;

  select m.id into v_first
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by m.joined_at
  limit 1;

  insert into public.fa_impostor_games(
    room_id,secret_catalog_id,secret_custom,hint,impostor_member_id,allowed_leagues,
    status,phase,round_no,current_questioner_member_id
  )
  values(
    p_room_id,p_secret_catalog_id,v_secret_custom,v_hint,v_impostor,'{}'::text[],
    'playing','question',1,v_first
  )
  returning * into v_game;

  return jsonb_build_object(
    'id',v_game.id,'status',v_game.status,'phase',v_game.phase,'round_no',v_game.round_no
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

  select * into v_room from public.fa_rooms where id=p_room_id;
  if not found or v_room.room_kind<>'impostor' then raise exception 'impostor room not found'; end if;

  select * into v_me from public.fa_room_members
  where room_id=p_room_id and user_id=v_user and kicked_at is null;
  if not found then raise exception 'not a room member'; end if;

  select * into v_game from public.fa_impostor_games
  where room_id=p_room_id order by created_at desc limit 1;

  if not found then
    return jsonb_build_object(
      'room_status',v_room.status,
      'has_game',false,
      'role',case
        when v_room.host_user_id=v_user and v_me.is_spectator then 'admin'
        when v_me.is_spectator then 'spectator'
        else 'player'
      end,
      'is_host',v_room.host_user_id=v_user,
      'admin_plays',case when v_room.host_user_id=v_user then not v_me.is_spectator else null end
    );
  end if;

  select exists(
    select 1 from public.fa_impostor_eliminations e
    where e.game_id=v_game.id and e.member_id=v_me.id
  ) into v_eliminated;

  v_role:=case
    when v_room.host_user_id=v_user and v_me.is_spectator then 'admin'
    when v_me.is_spectator then 'spectator'
    when v_eliminated then 'eliminated'
    when v_me.id=v_game.impostor_member_id then 'impostor'
    else 'innocent'
  end;

  v_show_secret:=v_role in ('admin','innocent','eliminated') or v_game.status='finished';
  v_show_impostor:=v_role='admin' or v_game.status='finished';

  if v_show_secret then
    if v_game.secret_custom is not null then
      v_secret:=v_game.secret_custom;
    else
      select jsonb_build_object(
        'id',c.id,
        'name',c.name,
        'club',c.club,
        'league',c.league,
        'nationality',c.nationality,
        'primary_position',c.primary_position,
        'overall',c.overall,
        'player_type',c.player_type,
        'image_url',c.image_url,
        'is_custom',false
      )
      into v_secret
      from public.fa_catalog_players c
      where c.id=v_game.secret_catalog_id;
    end if;
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

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'member_id',m.id,
      'name',m.display_name,
      'is_admin',m.user_id=v_room.host_user_id,
      'is_spectator',m.is_spectator,
      'eliminated',exists(
        select 1 from public.fa_impostor_eliminations e
        where e.game_id=v_game.id and e.member_id=m.id
      ),
      'alive',not m.is_spectator and m.kicked_at is null and not exists(
        select 1 from public.fa_impostor_eliminations e
        where e.game_id=v_game.id and e.member_id=m.id
      )
    )
    order by m.joined_at
  ),'[]'::jsonb)
  into v_members
  from public.fa_room_members m
  where m.room_id=p_room_id and m.kicked_at is null;

  if v_game.active_question_id is not null then
    select * into v_question
    from public.fa_impostor_questions
    where id=v_game.active_question_id;

    select to_jsonb(a) into v_my_answer
    from public.fa_impostor_answers a
    where a.question_id=v_question.id and a.member_id=v_me.id;

    select coalesce(jsonb_agg(
      jsonb_build_object('target_member_id',r.target_member_id,'rating',r.rating)
    ),'[]'::jsonb)
    into v_my_ratings
    from public.fa_impostor_ratings r
    where r.question_id=v_question.id and r.rater_member_id=v_me.id;

    if v_question.status in ('rating','completed') then
      select coalesce(jsonb_agg(
        jsonb_build_object('member_id',a.member_id,'name',m.display_name,'answer',a.answer_text)
        order by m.joined_at
      ),'[]'::jsonb)
      into v_answers
      from public.fa_impostor_answers a
      join public.fa_room_members m on m.id=a.member_id
      where a.question_id=v_question.id;
    end if;

    if v_question.status='completed' then
      select coalesce(jsonb_agg(
        jsonb_build_object(
          'rater_member_id',r.rater_member_id,
          'rater_name',rm.display_name,
          'target_member_id',r.target_member_id,
          'target_name',tm.display_name,
          'rating',r.rating
        )
        order by r.created_at
      ),'[]'::jsonb)
      into v_ratings
      from public.fa_impostor_ratings r
      join public.fa_room_members rm on rm.id=r.rater_member_id
      join public.fa_room_members tm on tm.id=r.target_member_id
      where r.question_id=v_question.id;
    end if;
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id',q.id,
      'round_no',q.round_no,
      'questioner_member_id',q.questioner_member_id,
      'questioner_name',qm.display_name,
      'question',q.question_text,
      'answers',(
        select coalesce(jsonb_agg(
          jsonb_build_object('member_id',a.member_id,'name',am.display_name,'answer',a.answer_text)
          order by am.joined_at
        ),'[]'::jsonb)
        from public.fa_impostor_answers a
        join public.fa_room_members am on am.id=a.member_id
        where a.question_id=q.id
      ),
      'ratings',(
        select coalesce(jsonb_agg(
          jsonb_build_object(
            'rater_member_id',r.rater_member_id,
            'rater_name',rm.display_name,
            'target_member_id',r.target_member_id,
            'target_name',tm.display_name,
            'rating',r.rating
          )
          order by r.created_at
        ),'[]'::jsonb)
        from public.fa_impostor_ratings r
        join public.fa_room_members rm on rm.id=r.rater_member_id
        join public.fa_room_members tm on tm.id=r.target_member_id
        where r.question_id=q.id
      )
    )
    order by q.round_no,q.created_at
  ),'[]'::jsonb)
  into v_history
  from public.fa_impostor_questions q
  join public.fa_room_members qm on qm.id=q.questioner_member_id
  where q.game_id=v_game.id and q.status='completed';

  select d.choice into v_decision_vote
  from public.fa_impostor_decision_votes d
  where d.game_id=v_game.id and d.round_no=v_game.round_no and d.member_id=v_me.id;

  select e.target_member_id into v_elimination_vote
  from public.fa_impostor_elimination_votes e
  where e.game_id=v_game.id and e.round_no=v_game.round_no
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
    'is_host',v_room.host_user_id=v_user,
    'admin_plays',case when v_room.host_user_id=v_user then not v_me.is_spectator else null end,
    'me_member_id',v_me.id,
    'secret_player',v_secret,
    'hint',v_hint,
    'impostor',v_impostor,
    'winner_side',v_game.winner_side,
    'allowed_leagues',to_jsonb(v_game.allowed_leagues),
    'current_questioner_member_id',v_game.current_questioner_member_id,
    'active_question',case when v_question.id is null then null else jsonb_build_object(
      'id',v_question.id,
      'questioner_member_id',v_question.questioner_member_id,
      'questioner_name',(select m.display_name from public.fa_room_members m where m.id=v_question.questioner_member_id),
      'question',v_question.question_text,
      'status',v_question.status,
      'answers',v_answers,
      'ratings',v_ratings
    ) end,
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

revoke all on function public.fa_create_impostor_room(text,boolean,text,boolean) from public,anon;
revoke all on function public.fa_create_impostor_room(text,boolean,text) from public,anon;
revoke all on function public.fa_start_impostor_game(uuid) from public,anon;
revoke all on function public.fa_start_impostor_hosted_game(uuid,text,jsonb,text) from public,anon;
revoke all on function public.fa_impostor_state(uuid) from public,anon;

grant execute on function public.fa_create_impostor_room(text,boolean,text,boolean) to authenticated;
grant execute on function public.fa_create_impostor_room(text,boolean,text) to authenticated;
grant execute on function public.fa_start_impostor_game(uuid) to authenticated;
grant execute on function public.fa_start_impostor_hosted_game(uuid,text,jsonb,text) to authenticated;
grant execute on function public.fa_impostor_state(uuid) to authenticated;
