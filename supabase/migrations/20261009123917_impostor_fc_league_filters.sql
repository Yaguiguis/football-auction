create or replace function public.fa_available_impostor_leagues()
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
begin
  if v_user is null then
    raise exception 'authentication required';
  end if;

  return coalesce((
    select jsonb_agg(x.league order by x.league)
    from (
      select distinct trim(c.league) as league
      from public.fa_catalog_players c
      where c.enabled
        and c.league is not null
        and trim(c.league)<>''
        and coalesce(c.metadata->>'source','')<>'impostor_custom'
    ) x
  ),'[]'::jsonb);
end;
$function$;

create or replace function public.fa_create_impostor_room(
  p_display_name text,
  p_spectators_allowed boolean,
  p_password text,
  p_admin_plays boolean,
  p_allowed_leagues text[]
)
returns table(room_id uuid,room_code text,member_id uuid)
language plpgsql
security definer
set search_path=''
as $function$
declare
  v record;
  v_allowed text[];
begin
  select coalesce(array_agg(distinct trim(x) order by trim(x)),'{}'::text[])
  into v_allowed
  from unnest(coalesce(p_allowed_leagues,'{}'::text[])) as selected(x)
  where trim(x)<>'';

  -- Backwards-compatible behavior: a missing selection means all available leagues.
  if cardinality(v_allowed)=0 then
    select coalesce(array_agg(distinct trim(c.league) order by trim(c.league)),'{}'::text[])
    into v_allowed
    from public.fa_catalog_players c
    where c.enabled
      and c.league is not null
      and trim(c.league)<>''
      and coalesce(c.metadata->>'source','')<>'impostor_custom';
  end if;

  if cardinality(v_allowed)=0 then
    raise exception 'no available leagues found';
  end if;

  if exists(
    select 1
    from unnest(v_allowed) as selected(league)
    where not exists(
      select 1
      from public.fa_catalog_players c
      where c.enabled
        and trim(c.league)=selected.league
        and coalesce(c.metadata->>'source','')<>'impostor_custom'
    )
  ) then
    raise exception 'one or more selected leagues are unavailable';
  end if;

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
    v_allowed,
    'skip',
    p_spectators_allowed,
    p_password,
    true,
    true
  );

  update public.fa_rooms
  set room_kind='impostor',
      max_players=2147483647,
      allowed_leagues=v_allowed
  where id=v.room_id;

  update public.fa_room_members
  set is_spectator=not coalesce(p_admin_plays,false),
      ready=false,
      balance=0
  where id=v.member_id;

  return query select v.room_id,v.room_code,v.member_id;
end;
$function$;

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
begin
  return query
  select *
  from public.fa_create_impostor_room(
    p_display_name,
    p_spectators_allowed,
    p_password,
    p_admin_plays,
    null::text[]
  );
end;
$function$;

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
  v_allowed text[];
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

  if v_room.allowed_leagues is null then
    select coalesce(array_agg(distinct trim(c.league) order by trim(c.league)),'{}'::text[])
    into v_allowed
    from public.fa_catalog_players c
    where c.enabled
      and c.league is not null
      and trim(c.league)<>''
      and coalesce(c.metadata->>'source','')<>'impostor_custom';
  else
    v_allowed:=v_room.allowed_leagues;
  end if;

  if cardinality(v_allowed)=0 then
    raise exception 'choose at least one league';
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
    where m.room_id=p_room_id
      and not m.is_spectator
      and m.kicked_at is null
      and m.last_seen_at>=now()-interval '30 seconds'
      and not m.ready
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
    and (v_room.allowed_leagues is null or c.league=any(v_room.allowed_leagues))
    and private.fa_catalog_allowed_for_room(p_room_id,c.id)
  order by random()
  limit 1;

  if v_secret is null then
    raise exception 'no eligible secret player found in the selected leagues';
  end if;

  v_hint:=private.fa_impostor_generate_hint(v_secret);

  select m.id into v_impostor
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by random()
  limit 1;

  select m.id into v_first
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and m.last_seen_at>=now()-interval '30 seconds'
  order by m.joined_at
  limit 1;

  insert into public.fa_impostor_games(
    room_id,secret_catalog_id,secret_custom,hint,impostor_member_id,allowed_leagues,
    status,phase,round_no,current_questioner_member_id
  )
  values(
    p_room_id,v_secret,null,v_hint,v_impostor,v_allowed,
    'playing','question',1,v_first
  )
  returning * into v_game;

  return jsonb_build_object(
    'id',v_game.id,
    'status',v_game.status,
    'phase',v_game.phase,
    'round_no',v_game.round_no,
    'allowed_leagues',to_jsonb(v_allowed)
  );
end;
$function$;

revoke all on function public.fa_available_impostor_leagues() from public,anon;
revoke all on function public.fa_create_impostor_room(text,boolean,text,boolean,text[]) from public,anon;
revoke all on function public.fa_create_impostor_room(text,boolean,text,boolean) from public,anon;
revoke all on function public.fa_create_impostor_room(text,boolean,text) from public,anon;
revoke all on function public.fa_start_impostor_game(uuid) from public,anon;

grant execute on function public.fa_available_impostor_leagues() to authenticated;
grant execute on function public.fa_create_impostor_room(text,boolean,text,boolean,text[]) to authenticated;
grant execute on function public.fa_create_impostor_room(text,boolean,text,boolean) to authenticated;
grant execute on function public.fa_create_impostor_room(text,boolean,text) to authenticated;
grant execute on function public.fa_start_impostor_game(uuid) to authenticated;
