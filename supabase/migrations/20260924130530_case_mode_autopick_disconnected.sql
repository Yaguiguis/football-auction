
create or replace function private.fa_case_award_pick(
  p_round_id uuid,
  p_member_id uuid,
  p_case_no integer,
  p_created_by uuid
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_round public.fa_case_rounds%rowtype;
  v_member public.fa_room_members%rowtype;
  v_catalog public.fa_catalog_players%rowtype;
  v_catalog_id text;
  v_player_id text;
  v_pick public.fa_case_picks%rowtype;
begin
  select * into v_round
  from public.fa_case_rounds
  where id=p_round_id;

  if not found then raise exception 'round not found'; end if;

  select * into v_member
  from public.fa_room_members
  where id=p_member_id
    and room_id=v_round.room_id
    and kicked_at is null
    and not is_spectator;

  if not found then raise exception 'member not available'; end if;

  if exists(
    select 1 from public.fa_case_picks
    where round_id=p_round_id and member_id=p_member_id
  ) then raise exception 'member already picked'; end if;

  if exists(
    select 1 from public.fa_case_picks
    where round_id=p_round_id and case_no=p_case_no
  ) then raise exception 'case already taken'; end if;

  select catalog_id into v_catalog_id
  from private.fa_case_options
  where round_id=p_round_id and case_no=p_case_no;

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
    coalesce(p_created_by,v_member.user_id),
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

  return jsonb_build_object(
    'pick',to_jsonb(v_pick),
    'player',(select to_jsonb(p) from public.fa_players p where p.id=v_player_id)
  );
end;
$function$;

create or replace function private.fa_case_close_round_if_ready(p_round_id uuid)
returns boolean
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_round public.fa_case_rounds%rowtype;
  v_member record;
  v_case_no integer;
begin
  select * into v_round
  from public.fa_case_rounds
  where id=p_round_id
  for update;

  if not found then return false; end if;
  if v_round.status='completed' then return true; end if;

  -- Jogadores online ainda precisam escolher por conta própria.
  if exists(
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
  ) then
    return false;
  end if;

  -- Quem ficou offline recebe uma das maletas restantes para não quebrar o elenco.
  for v_member in
    select m.id,m.user_id
    from public.fa_room_members m
    where m.room_id=v_round.room_id
      and not m.is_spectator
      and m.kicked_at is null
      and not exists(
        select 1
        from public.fa_case_picks p
        where p.round_id=v_round.id
          and p.member_id=m.id
      )
    order by m.joined_at
  loop
    select o.case_no into v_case_no
    from private.fa_case_options o
    where o.round_id=v_round.id
      and not exists(
        select 1
        from public.fa_case_picks p
        where p.round_id=v_round.id
          and p.case_no=o.case_no
      )
    order by random()
    limit 1;

    if v_case_no is null then
      raise exception 'no case left for disconnected player';
    end if;

    perform private.fa_case_award_pick(
      v_round.id,
      v_member.id,
      v_case_no,
      v_member.user_id
    );
  end loop;

  update public.fa_case_rounds
  set status='completed',completed_at=coalesce(completed_at,now())
  where id=v_round.id;

  return true;
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
  v_participants integer;
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

  select count(*) into v_participants
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null;

  if v_participants<1 then raise exception 'no players in room'; end if;

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

  if v_available<v_participants then
    raise exception 'not enough eligible cards for this position';
  end if;

  v_case_count:=least(v_available,v_participants+2);

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
  v_award jsonb;
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
  ) then raise exception 'you already chose a case this round'; end if;

  if exists(
    select 1 from public.fa_case_picks
    where round_id=v_round.id and case_no=p_case_no
  ) then raise exception 'this case was already taken'; end if;

  v_award:=private.fa_case_award_pick(
    v_round.id,
    v_member.id,
    p_case_no,
    v_user
  );

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

  return v_award || jsonb_build_object(
    'round_complete',v_complete,
    'all_slots_done',v_all_done
  );
end;
$function$;

revoke all on function public.fa_start_case_round(uuid,text) from public,anon;
revoke all on function public.fa_pick_case(uuid,integer) from public,anon;
grant execute on function public.fa_start_case_round(uuid,text) to authenticated;
grant execute on function public.fa_pick_case(uuid,integer) to authenticated;
