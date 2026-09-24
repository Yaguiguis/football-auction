
create or replace function public.fa_reconfigure_room(
  p_room_id uuid,
  p_room_kind text,
  p_mode text,
  p_budget integer,
  p_reserve_count integer,
  p_allow_icons boolean,
  p_allow_base boolean,
  p_allow_specials boolean,
  p_min_overall integer,
  p_max_overall integer,
  p_active_only boolean,
  p_allowed_leagues text[],
  p_disconnect_mode text,
  p_spectators_allowed boolean,
  p_tournament_size integer default null,
  p_password_action text default 'keep',
  p_password text default null
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_player_count integer;
  v_new_password_hash text;
  v_has_progress boolean;
begin
  if v_user is null then
    raise exception 'authentication required';
  end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then
    raise exception 'room not found';
  end if;

  if v_room.host_user_id<>v_user then
    raise exception 'only host can change room settings';
  end if;

  if v_room.status='auction' then
    raise exception 'finish the current game before changing room settings';
  end if;

  if v_room.status not in ('lobby','squads','finished') then
    raise exception 'room settings cannot be changed now';
  end if;

  if p_room_kind not in ('auction','cases','tournament') then
    raise exception 'invalid room kind';
  end if;

  if p_mode not in ('football','futsal') then
    raise exception 'invalid mode';
  end if;

  if p_budget<1 or p_budget>100000 then
    raise exception 'invalid budget';
  end if;

  if p_reserve_count<0 or p_reserve_count>5 then
    raise exception 'invalid reserve count';
  end if;

  if p_min_overall<1 or p_max_overall>100 or p_min_overall>p_max_overall then
    raise exception 'invalid overall range';
  end if;

  if p_disconnect_mode not in ('skip','bot') then
    raise exception 'invalid disconnect mode';
  end if;

  if not (
    coalesce(p_allow_base,false)
    or (coalesce(p_allow_icons,false) and not coalesce(p_active_only,false))
    or (coalesce(p_allow_specials,false) and not coalesce(p_active_only,false))
  ) then
    raise exception 'select at least one compatible card type';
  end if;

  if p_room_kind='tournament' then
    if p_tournament_size not in (4,8,16) then
      raise exception 'tournament size must be 4, 8 or 16';
    end if;

    select count(*) into v_player_count
    from public.fa_room_members
    where room_id=p_room_id
      and kicked_at is null
      and not is_spectator;

    if v_player_count>p_tournament_size then
      raise exception 'tournament size is smaller than the current number of players';
    end if;
  end if;

  if p_password_action not in ('keep','set','clear') then
    raise exception 'invalid password action';
  end if;

  if p_password_action='set' then
    if p_password is null or trim(p_password)='' then
      raise exception 'enter a password';
    end if;
    if char_length(p_password)>32 then
      raise exception 'password too long';
    end if;
    v_new_password_hash:=extensions.crypt(p_password,extensions.gen_salt('bf'));
  elsif p_password_action='clear' then
    v_new_password_hash:=null;
  else
    v_new_password_hash:=v_room.password_hash;
  end if;

  select
    exists(select 1 from public.fa_players where room_id=p_room_id)
    or exists(select 1 from public.fa_auctions where room_id=p_room_id)
    or exists(select 1 from public.fa_case_rounds where room_id=p_room_id)
    or exists(select 1 from public.fa_tournament_matches where room_id=p_room_id)
    or exists(
      select 1
      from public.fa_squad_players s
      join public.fa_room_members m on m.id=s.member_id
      where m.room_id=p_room_id
    )
  into v_has_progress;

  if v_has_progress then
    insert into public.fa_round_archives(room_id,snapshot)
    values(
      p_room_id,
      jsonb_build_object(
        'archive_reason','room_reconfigured',
        'previous_room_kind',v_room.room_kind,
        'previous_mode',v_room.mode,
        'players',(
          select coalesce(jsonb_agg(to_jsonb(p)),'[]'::jsonb)
          from public.fa_players p
          where p.room_id=p_room_id
        ),
        'auctions',(
          select coalesce(jsonb_agg(to_jsonb(a)),'[]'::jsonb)
          from public.fa_auctions a
          where a.room_id=p_room_id
        ),
        'case_rounds',(
          select coalesce(jsonb_agg(to_jsonb(r) order by r.round_no),'[]'::jsonb)
          from public.fa_case_rounds r
          where r.room_id=p_room_id
        ),
        'case_picks',(
          select coalesce(jsonb_agg(to_jsonb(cp) order by cp.created_at),'[]'::jsonb)
          from public.fa_case_picks cp
          where cp.room_id=p_room_id
        ),
        'squads',(
          select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb)
          from public.fa_squad_players s
          join public.fa_room_members m on m.id=s.member_id
          where m.room_id=p_room_id
        ),
        'tournament_matches',(
          select coalesce(jsonb_agg(to_jsonb(t) order by t.round_no,t.match_no),'[]'::jsonb)
          from public.fa_tournament_matches t
          where t.room_id=p_room_id
        ),
        'members',(
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'id',m.id,
                'display_name',m.display_name,
                'balance',m.balance,
                'squad_finalized',m.squad_finalized
              )
              order by m.joined_at
            ),
            '[]'::jsonb
          )
          from public.fa_room_members m
          where m.room_id=p_room_id
        )
      )
    );
  end if;

  delete from public.fa_trade_requests where room_id=p_room_id;
  delete from public.fa_tournament_matches where room_id=p_room_id;
  delete from public.fa_case_rounds where room_id=p_room_id;

  delete from public.fa_squad_players s
  using public.fa_room_members m
  where s.member_id=m.id
    and m.room_id=p_room_id;

  delete from public.fa_auctions where room_id=p_room_id;
  delete from public.fa_players where room_id=p_room_id;

  delete from public.fa_x1_matches where room_id=p_room_id;

  update public.fa_room_members
  set balance=case when is_spectator then 0 else p_budget end,
      squad_finalized=false,
      finalized_at=null,
      replay_requested=false,
      ready=false,
      last_seen_at=case when user_id=v_user then now() else last_seen_at end
  where room_id=p_room_id;

  update public.fa_rooms
  set room_kind=p_room_kind,
      mode=p_mode,
      budget=p_budget,
      reserve_count=p_reserve_count,
      allow_icons=p_allow_icons,
      allow_base=p_allow_base,
      allow_specials=p_allow_specials,
      min_overall=p_min_overall,
      max_overall=p_max_overall,
      active_only=p_active_only,
      allowed_leagues=case
        when p_allowed_leagues is null or cardinality(p_allowed_leagues)=0 then null
        else p_allowed_leagues
      end,
      disconnect_mode=p_disconnect_mode,
      spectators_allowed=p_spectators_allowed,
      password_hash=v_new_password_hash,
      max_players=case
        when p_room_kind='tournament' then p_tournament_size
        else 2147483647
      end,
      tournament_size=case
        when p_room_kind='tournament' then p_tournament_size
        else null
      end,
      tournament_champion_member_id=null,
      status='lobby'
  where id=p_room_id
  returning * into v_room;

  return jsonb_build_object(
    'room',to_jsonb(v_room),
    'progress_reset',v_has_progress,
    'chat_preserved',true,
    'members_preserved',true
  );
end;
$function$;

revoke all on function public.fa_reconfigure_room(
  uuid,text,text,integer,integer,boolean,boolean,boolean,integer,integer,boolean,text[],text,boolean,integer,text,text
) from public,anon;

grant execute on function public.fa_reconfigure_room(
  uuid,text,text,integer,integer,boolean,boolean,boolean,integer,integer,boolean,text[],text,boolean,integer,text,text
) to authenticated;
