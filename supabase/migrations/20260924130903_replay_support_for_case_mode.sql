
create or replace function public.fa_request_replay(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_member public.fa_room_members%rowtype;
  v_requests integer;
  v_total integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.status not in ('squads','finished') then
    raise exception 'replay is only available after everyone finishes';
  end if;

  select * into v_member
  from public.fa_room_members
  where room_id=p_room_id and user_id=v_user
  for update;

  if not found then raise exception 'not a room member'; end if;
  if v_member.is_spectator then raise exception 'spectators cannot request replay'; end if;

  update public.fa_room_members
  set replay_requested=true,last_seen_at=now()
  where id=v_member.id;

  select count(*) into v_requests
  from public.fa_room_members
  where room_id=p_room_id
    and not is_spectator
    and replay_requested;

  select count(*) into v_total
  from public.fa_room_members
  where room_id=p_room_id and not is_spectator;

  if v_room.host_user_id<>v_user then
    return jsonb_build_object(
      'restarted',false,
      'waiting_for_host',true,
      'requests',v_requests,
      'total',v_total
    );
  end if;

  insert into public.fa_round_archives(room_id,snapshot)
  values(
    p_room_id,
    jsonb_build_object(
      'players',(select coalesce(jsonb_agg(to_jsonb(p)),'[]'::jsonb) from public.fa_players p where p.room_id=p_room_id),
      'auctions',(select coalesce(jsonb_agg(to_jsonb(a)),'[]'::jsonb) from public.fa_auctions a where a.room_id=p_room_id),
      'bids',(select coalesce(jsonb_agg(to_jsonb(b)),'[]'::jsonb) from public.fa_bids b join public.fa_auctions a on a.id=b.auction_id where a.room_id=p_room_id),
      'case_rounds',(select coalesce(jsonb_agg(to_jsonb(r) order by r.round_no),'[]'::jsonb) from public.fa_case_rounds r where r.room_id=p_room_id),
      'case_picks',(select coalesce(jsonb_agg(to_jsonb(cp) order by cp.created_at),'[]'::jsonb) from public.fa_case_picks cp where cp.room_id=p_room_id),
      'squads',(select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb) from public.fa_squad_players s join public.fa_room_members m on m.id=s.member_id where m.room_id=p_room_id),
      'members',(select coalesce(jsonb_agg(jsonb_build_object('id',m.id,'display_name',m.display_name,'balance',m.balance)),'[]'::jsonb) from public.fa_room_members m where m.room_id=p_room_id),
      'tournament_matches',(select coalesce(jsonb_agg(to_jsonb(t) order by t.round_no,t.match_no),'[]'::jsonb) from public.fa_tournament_matches t where t.room_id=p_room_id),
      'tournament_champion_member_id',v_room.tournament_champion_member_id,
      'room_kind',v_room.room_kind
    )
  );

  update public.fa_x1_matches
  set status='cancelled',responded_at=now()
  where room_id=p_room_id and status='pending';

  delete from public.fa_tournament_matches where room_id=p_room_id;
  delete from public.fa_case_rounds where room_id=p_room_id;

  delete from public.fa_squad_players s
  using public.fa_room_members m
  where s.member_id=m.id and m.room_id=p_room_id;

  delete from public.fa_auctions where room_id=p_room_id;
  delete from public.fa_players where room_id=p_room_id;

  update public.fa_room_members
  set balance=case when is_spectator then 0 else v_room.budget end,
      squad_finalized=false,
      finalized_at=null,
      replay_requested=false,
      ready=false,
      last_seen_at=case when user_id=v_user then now() else last_seen_at end
  where room_id=p_room_id;

  update public.fa_rooms
  set status='lobby',
      tournament_champion_member_id=null
  where id=p_room_id;

  return jsonb_build_object(
    'restarted',true,
    'waiting_for_host',false,
    'requests',0,
    'total',v_total
  );
end;
$function$;

revoke all on function public.fa_request_replay(uuid) from public,anon;
grant execute on function public.fa_request_replay(uuid) to authenticated;
