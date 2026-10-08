alter table public.fa_impostor_games
  add column if not exists allowed_leagues text[] not null default '{}';

create index if not exists fa_impostor_games_allowed_leagues_gin_idx
  on public.fa_impostor_games using gin (allowed_leagues);

create or replace function public.fa_impostor_leagues(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if not exists(
    select 1 from public.fa_rooms r
    where r.id=p_room_id and r.room_kind='impostor' and r.host_user_id=v_user
  ) then raise exception 'only host can browse impostor leagues'; end if;

  return coalesce((
    select jsonb_agg(x.league order by x.league)
    from (
      select distinct trim(c.league) as league
      from public.fa_catalog_players c
      where c.enabled and c.league is not null and trim(c.league)<>''
        and coalesce(c.metadata->>'source','') <> 'impostor_custom'
    ) x
  ),'[]'::jsonb);
end;
$function$;

drop function if exists public.fa_start_impostor_game(uuid,text,text);

create or replace function private.fa_impostor_generate_hint(p_catalog_id text)
returns text
language plpgsql
security definer
set search_path=''
as $function$
declare
  c public.fa_catalog_players%rowtype;
  v_options text[]:=array[]::text[];
begin
  select * into c from public.fa_catalog_players where id=p_catalog_id and enabled;
  if not found then raise exception 'secret player not found'; end if;

  if nullif(trim(coalesce(c.club,'')),'') is not null then
    v_options:=array_append(v_options,'Joga pelo clube '||trim(c.club));
  end if;
  if nullif(trim(coalesce(c.league,'')),'') is not null then
    v_options:=array_append(v_options,'Atua na liga '||trim(c.league));
  end if;
  if nullif(trim(coalesce(c.primary_position,'')),'') is not null then
    v_options:=array_append(v_options,'A posição principal é '||trim(c.primary_position));
  end if;
  if nullif(trim(coalesce(c.nationality,'')),'') is not null then
    v_options:=array_append(v_options,'É da seleção de '||trim(c.nationality));
  end if;

  if cardinality(v_options)=0 then raise exception 'secret player has no usable hint'; end if;
  return v_options[1 + floor(random()*cardinality(v_options))::integer];
end;
$function$;

create or replace function public.fa_start_impostor_game(
  p_room_id uuid,
  p_allowed_leagues text[]
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
  v_allowed text[];
  v_secret text;
  v_hint text;
  v_player_count integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  select * into v_room from public.fa_rooms where id=p_room_id for update;
  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'only host can configure the game'; end if;
  if v_room.room_kind<>'impostor' then raise exception 'not an impostor room'; end if;
  if v_room.status<>'auction' then raise exception 'impostor mode is not waiting for setup'; end if;

  select coalesce(array_agg(distinct trim(x) order by trim(x)),'{}'::text[])
  into v_allowed
  from unnest(coalesce(p_allowed_leagues,'{}'::text[])) x
  where trim(x)<>'';

  if cardinality(v_allowed)=0 then raise exception 'choose at least one league'; end if;

  if exists(
    select 1 from unnest(v_allowed) x
    where not exists(
      select 1 from public.fa_catalog_players c
      where c.enabled and c.league=trim(x)
        and coalesce(c.metadata->>'source','') <> 'impostor_custom'
    )
  ) then raise exception 'one or more selected leagues have no eligible players'; end if;

  select count(*) into v_player_count
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds';

  if v_player_count<4 then raise exception 'at least four active players are required'; end if;

  if exists(
    select 1 from public.fa_room_members m
    where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
      and m.last_seen_at>=now()-interval '30 seconds' and not m.ready
  ) then raise exception 'all active players must be ready'; end if;

  if exists(select 1 from public.fa_impostor_games g where g.room_id=p_room_id and g.status='playing') then
    raise exception 'game already started';
  end if;

  select c.id into v_secret
  from public.fa_catalog_players c
  where c.enabled and c.league=any(v_allowed)
    and coalesce(c.metadata->>'source','') <> 'impostor_custom'
  order by random() limit 1;

  if v_secret is null then raise exception 'no eligible secret player found'; end if;
  v_hint:=private.fa_impostor_generate_hint(v_secret);

  select m.id into v_impostor
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by random() limit 1;

  select m.id into v_first
  from public.fa_room_members m
  where m.room_id=p_room_id and not m.is_spectator and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by m.joined_at limit 1;

  insert into public.fa_impostor_games(
    room_id,secret_catalog_id,hint,impostor_member_id,allowed_leagues,
    status,phase,round_no,current_questioner_member_id
  )
  values(
    p_room_id,v_secret,v_hint,v_impostor,v_allowed,
    'playing','question',1,v_first
  )
  returning * into v_game;

  return jsonb_build_object('id',v_game.id,'status',v_game.status,'phase',v_game.phase,'round_no',v_game.round_no);
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
declare v record;
begin
  select * into v from public.fa_create_room_v3(
    p_display_name,'futsal',100,0,true,1,100,false,null,'skip',
    p_spectators_allowed,p_password,true,true
  );

  update public.fa_rooms set room_kind='impostor',max_players=2147483647 where id=v.room_id;
  update public.fa_room_members set is_spectator=false,ready=false,balance=0 where id=v.member_id;
  return query select v.room_id,v.room_code,v.member_id;
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

  select * into v_game from public.fa_impostor_games where room_id=p_room_id order by created_at desc limit 1;

  if not found then
    return jsonb_build_object(
      'room_status',v_room.status,'has_game',false,
      'role',case when v_room.host_user_id=v_user then 'admin'
                  when v_me.is_spectator then 'spectator' else 'player' end
    );
  end if;

  select exists(select 1 from public.fa_impostor_eliminations e where e.game_id=v_game.id and e.member_id=v_me.id)
  into v_eliminated;

  v_role:=case
    when v_me.is_spectator then 'spectator'
    when v_eliminated then 'eliminated'
    when v_me.id=v_game.impostor_member_id then 'impostor'
    else 'innocent'
  end;

  v_show_secret:=v_role in ('innocent','eliminated') or v_game.status='finished';
  v_show_impostor:=v_game.status='finished';

  if v_show_secret then
    select jsonb_build_object(
      'id',c.id,'name',c.name,'club',c.club,'league',c.league,'nationality',c.nationality,
      'primary_position',c.primary_position,'overall',c.overall,'player_type',c.player_type,'image_url',c.image_url
    ) into v_secret
    from public.fa_catalog_players c where c.id=v_game.secret_catalog_id;
  end if;

  if v_role='impostor' or v_game.status='finished' then v_hint:=v_game.hint; end if;

  if v_show_impostor then
    select jsonb_build_object('member_id',m.id,'name',m.display_name)
    into v_impostor from public.fa_room_members m where m.id=v_game.impostor_member_id;
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'member_id',m.id,'name',m.display_name,'is_admin',m.user_id=v_room.host_user_id,
      'is_spectator',m.is_spectator,
      'eliminated',exists(select 1 from public.fa_impostor_eliminations e where e.game_id=v_game.id and e.member_id=m.id),
      'alive',not m.is_spectator and m.kicked_at is null and not exists(
        select 1 from public.fa_impostor_eliminations e where e.game_id=v_game.id and e.member_id=m.id
      )
    ) order by m.joined_at
  ),'[]'::jsonb) into v_members
  from public.fa_room_members m where m.room_id=p_room_id and m.kicked_at is null;

  if v_game.active_question_id is not null then
    select * into v_question from public.fa_impostor_questions where id=v_game.active_question_id;
    select to_jsonb(a) into v_my_answer from public.fa_impostor_answers a
    where a.question_id=v_question.id and a.member_id=v_me.id;

    select coalesce(jsonb_agg(jsonb_build_object('target_member_id',r.target_member_id,'rating',r.rating)),'[]'::jsonb)
    into v_my_ratings from public.fa_impostor_ratings r
    where r.question_id=v_question.id and r.rater_member_id=v_me.id;

    if v_question.status in ('rating','completed') then
      select coalesce(jsonb_agg(
        jsonb_build_object('member_id',a.member_id,'name',m.display_name,'answer',a.answer_text)
        order by m.joined_at
      ),'[]'::jsonb) into v_answers
      from public.fa_impostor_answers a join public.fa_room_members m on m.id=a.member_id
      where a.question_id=v_question.id;
    end if;

    if v_question.status='completed' then
      select coalesce(jsonb_agg(
        jsonb_build_object('rater_member_id',r.rater_member_id,'rater_name',rm.display_name,
          'target_member_id',r.target_member_id,'target_name',tm.display_name,'rating',r.rating)
        order by r.created_at
      ),'[]'::jsonb) into v_ratings
      from public.fa_impostor_ratings r
      join public.fa_room_members rm on rm.id=r.rater_member_id
      join public.fa_room_members tm on tm.id=r.target_member_id
      where r.question_id=v_question.id;
    end if;
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id',q.id,'round_no',q.round_no,'questioner_member_id',q.questioner_member_id,
      'questioner_name',qm.display_name,'question',q.question_text,
      'answers',(select coalesce(jsonb_agg(
        jsonb_build_object('member_id',a.member_id,'name',am.display_name,'answer',a.answer_text)
        order by am.joined_at
      ),'[]'::jsonb) from public.fa_impostor_answers a
        join public.fa_room_members am on am.id=a.member_id where a.question_id=q.id),
      'ratings',(select coalesce(jsonb_agg(
        jsonb_build_object('rater_member_id',r.rater_member_id,'rater_name',rm.display_name,
          'target_member_id',r.target_member_id,'target_name',tm.display_name,'rating',r.rating)
        order by r.created_at
      ),'[]'::jsonb) from public.fa_impostor_ratings r
        join public.fa_room_members rm on rm.id=r.rater_member_id
        join public.fa_room_members tm on tm.id=r.target_member_id where r.question_id=q.id)
    ) order by q.round_no,q.created_at
  ),'[]'::jsonb) into v_history
  from public.fa_impostor_questions q
  join public.fa_room_members qm on qm.id=q.questioner_member_id
  where q.game_id=v_game.id and q.status='completed';

  select d.choice into v_decision_vote from public.fa_impostor_decision_votes d
  where d.game_id=v_game.id and d.round_no=v_game.round_no and d.member_id=v_me.id;

  select e.target_member_id into v_elimination_vote from public.fa_impostor_elimination_votes e
  where e.game_id=v_game.id and e.round_no=v_game.round_no
    and e.stage=case when v_game.phase='runoff' then 2 else 1 end
    and e.voter_member_id=v_me.id;

  return jsonb_build_object(
    'room_status',v_room.status,'has_game',true,'game_id',v_game.id,'status',v_game.status,
    'phase',v_game.phase,'round_no',v_game.round_no,'role',v_role,'me_member_id',v_me.id,
    'secret_player',v_secret,'hint',v_hint,'impostor',v_impostor,'winner_side',v_game.winner_side,
    'allowed_leagues',to_jsonb(v_game.allowed_leagues),
    'current_questioner_member_id',v_game.current_questioner_member_id,
    'active_question',case when v_question.id is null then null else jsonb_build_object(
      'id',v_question.id,'questioner_member_id',v_question.questioner_member_id,
      'questioner_name',(select m.display_name from public.fa_room_members m where m.id=v_question.questioner_member_id),
      'question',v_question.question_text,'status',v_question.status,'answers',v_answers,'ratings',v_ratings
    ) end,
    'my_answer',v_my_answer,'my_ratings',v_my_ratings,'my_decision_vote',v_decision_vote,
    'my_elimination_vote',v_elimination_vote,'last_decision',v_game.last_decision,
    'last_elimination',v_game.last_elimination,'runoff_candidates',coalesce(to_jsonb(v_game.runoff_candidates),'[]'::jsonb),
    'members',v_members,'history',v_history
  );
end;
$function$;

drop function if exists public.fa_impostor_catalog(uuid,text);


revoke all on function public.fa_impostor_leagues(uuid) from public,anon;
revoke all on function public.fa_start_impostor_game(uuid,text[]) from public,anon;
grant execute on function public.fa_impostor_leagues(uuid) to authenticated;
grant execute on function public.fa_start_impostor_game(uuid,text[]) to authenticated;
