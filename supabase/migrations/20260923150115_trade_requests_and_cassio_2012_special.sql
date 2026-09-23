create table if not exists public.fa_trade_requests (
  id uuid primary key default extensions.gen_random_uuid(),
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  requester_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  recipient_member_id uuid not null references public.fa_room_members(id) on delete cascade,
  offered_player_id text not null references public.fa_players(id) on delete cascade,
  requested_player_id text not null references public.fa_players(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending','accepted','declined','cancelled')),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  check (requester_member_id <> recipient_member_id),
  check (offered_player_id <> requested_player_id)
);

create index if not exists fa_trade_requests_room_created_idx
  on public.fa_trade_requests(room_id,created_at desc);
create index if not exists fa_trade_requests_recipient_status_idx
  on public.fa_trade_requests(recipient_member_id,status);
create index if not exists fa_trade_requests_requester_status_idx
  on public.fa_trade_requests(requester_member_id,status);

alter table public.fa_trade_requests enable row level security;

drop policy if exists fa_trade_requests_select_participants on public.fa_trade_requests;
create policy fa_trade_requests_select_participants
on public.fa_trade_requests
for select
to authenticated
using (
  exists (
    select 1
    from public.fa_room_members me
    where me.room_id=fa_trade_requests.room_id
      and me.user_id=(select auth.uid())
      and me.kicked_at is null
      and me.id in (
        fa_trade_requests.requester_member_id,
        fa_trade_requests.recipient_member_id
      )
  )
);

revoke all on public.fa_trade_requests from anon, public;
grant select on public.fa_trade_requests to authenticated;

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname='supabase_realtime'
      and schemaname='public'
      and tablename='fa_trade_requests'
  ) then
    alter publication supabase_realtime add table public.fa_trade_requests;
  end if;
end $$;

create or replace function public.fa_create_trade_request(
  p_room_id uuid,
  p_offered_player_id text,
  p_recipient_member_id uuid,
  p_requested_player_id text
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_requester public.fa_room_members%rowtype;
  v_recipient public.fa_room_members%rowtype;
  v_offer public.fa_squad_players%rowtype;
  v_request public.fa_squad_players%rowtype;
  v_trade public.fa_trade_requests%rowtype;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.status in ('squads','finished') then
    raise exception 'trades are closed for this room';
  end if;

  select * into v_requester
  from public.fa_room_members
  where room_id=p_room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator
  for update;

  if not found then raise exception 'not a room player'; end if;
  if v_requester.squad_finalized then raise exception 'your squad is already finalized'; end if;

  select * into v_recipient
  from public.fa_room_members
  where id=p_recipient_member_id
    and room_id=p_room_id
    and kicked_at is null
    and not is_spectator
  for update;

  if not found then raise exception 'trade recipient not found'; end if;
  if v_recipient.id=v_requester.id then raise exception 'cannot trade with yourself'; end if;
  if v_recipient.squad_finalized then raise exception 'the other squad is already finalized'; end if;

  select * into v_offer
  from public.fa_squad_players
  where member_id=v_requester.id
    and player_id=p_offered_player_id
  for update;

  if not found then raise exception 'offered player is not in your squad'; end if;

  select * into v_request
  from public.fa_squad_players
  where member_id=v_recipient.id
    and player_id=p_requested_player_id
  for update;

  if not found then raise exception 'requested player is no longer in that squad'; end if;

  if exists (
    select 1
    from public.fa_trade_requests t
    where t.room_id=p_room_id
      and t.status='pending'
      and (
        t.offered_player_id in (p_offered_player_id,p_requested_player_id)
        or t.requested_player_id in (p_offered_player_id,p_requested_player_id)
      )
  ) then
    raise exception 'one of these players already has a pending trade';
  end if;

  insert into public.fa_trade_requests(
    room_id,
    requester_member_id,
    recipient_member_id,
    offered_player_id,
    requested_player_id
  )
  values(
    p_room_id,
    v_requester.id,
    v_recipient.id,
    p_offered_player_id,
    p_requested_player_id
  )
  returning * into v_trade;

  return to_jsonb(v_trade);
end;
$function$;

create or replace function public.fa_respond_trade_request(
  p_trade_id uuid,
  p_accept boolean
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_trade public.fa_trade_requests%rowtype;
  v_requester public.fa_room_members%rowtype;
  v_recipient public.fa_room_members%rowtype;
  v_offer public.fa_squad_players%rowtype;
  v_request public.fa_squad_players%rowtype;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_trade
  from public.fa_trade_requests
  where id=p_trade_id
  for update;

  if not found then raise exception 'trade not found'; end if;
  if v_trade.status<>'pending' then return to_jsonb(v_trade); end if;

  select * into v_recipient
  from public.fa_room_members
  where id=v_trade.recipient_member_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator
  for update;

  if not found then raise exception 'only the recipient can respond'; end if;

  if not p_accept then
    update public.fa_trade_requests
    set status='declined',responded_at=now()
    where id=v_trade.id
    returning * into v_trade;

    return to_jsonb(v_trade);
  end if;

  select * into v_requester
  from public.fa_room_members
  where id=v_trade.requester_member_id
    and room_id=v_trade.room_id
    and kicked_at is null
    and not is_spectator
  for update;

  if not found then raise exception 'requester is no longer available'; end if;
  if v_requester.squad_finalized or v_recipient.squad_finalized then
    raise exception 'one of the squads is already finalized';
  end if;

  select * into v_offer
  from public.fa_squad_players
  where member_id=v_requester.id
    and player_id=v_trade.offered_player_id
  for update;

  if not found then raise exception 'offered player changed squads'; end if;

  select * into v_request
  from public.fa_squad_players
  where member_id=v_recipient.id
    and player_id=v_trade.requested_player_id
  for update;

  if not found then raise exception 'requested player changed squads'; end if;

  delete from public.fa_squad_players
  where id in (v_offer.id,v_request.id);

  insert into public.fa_squad_players(member_id,player_id,slot_key,is_bench)
  values
    (v_requester.id,v_trade.requested_player_id,v_offer.slot_key,v_offer.is_bench),
    (v_recipient.id,v_trade.offered_player_id,v_request.slot_key,v_request.is_bench);

  update public.fa_trade_requests
  set status='accepted',responded_at=now()
  where id=v_trade.id
  returning * into v_trade;

  update public.fa_trade_requests
  set status='cancelled',responded_at=now()
  where room_id=v_trade.room_id
    and id<>v_trade.id
    and status='pending'
    and (
      offered_player_id in (v_trade.offered_player_id,v_trade.requested_player_id)
      or requested_player_id in (v_trade.offered_player_id,v_trade.requested_player_id)
    );

  return to_jsonb(v_trade);
end;
$function$;

create or replace function public.fa_cancel_trade_request(p_trade_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_trade public.fa_trade_requests%rowtype;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select t.* into v_trade
  from public.fa_trade_requests t
  join public.fa_room_members m on m.id=t.requester_member_id
  where t.id=p_trade_id
    and m.user_id=v_user
    and m.kicked_at is null
  for update of t;

  if not found then raise exception 'trade not found'; end if;

  if v_trade.status='pending' then
    update public.fa_trade_requests
    set status='cancelled',responded_at=now()
    where id=v_trade.id
    returning * into v_trade;
  end if;

  return to_jsonb(v_trade);
end;
$function$;

revoke all on function public.fa_create_trade_request(uuid,text,uuid,text) from public,anon;
revoke all on function public.fa_respond_trade_request(uuid,boolean) from public,anon;
revoke all on function public.fa_cancel_trade_request(uuid) from public,anon;

grant execute on function public.fa_create_trade_request(uuid,text,uuid,text) to authenticated;
grant execute on function public.fa_respond_trade_request(uuid,boolean) to authenticated;
grant execute on function public.fa_cancel_trade_request(uuid) to authenticated;

insert into public.fa_catalog_players(
  id,name,league,nationality,primary_position,player_type,legend_region,overall,enabled,
  metadata,image_url,image_source_url,image_license,club,secondary_positions,
  canonical_key,slug,season_year,version_label
)
select
  'cassio-2012-special','Cássio',c.league,c.nationality,'GOL','SPECIAL',
  c.legend_region,99,true,
  c.metadata || jsonb_build_object(
    'theme','world-stars',
    'season_year',2012,
    'version_label','2012',
    'rating_source','Football Auction game design',
    'rating_status','custom_game_design',
    'not_official_ea_fc27',true,
    'image_reused_from','bra_cassio',
    'special_role','goalkeeper',
    'special_club','Corinthians'
  ),
  c.image_url,c.image_source_url,c.image_license,coalesce(c.club,'Corinthians'),
  array[]::text[],c.canonical_key,'cassio-2012-special',2012,'2012'
from public.fa_catalog_players c
where c.id='bra_cassio'
on conflict(id) do update set
  overall=99,
  enabled=true,
  player_type='SPECIAL',
  primary_position='GOL',
  season_year=2012,
  version_label='2012',
  image_url=excluded.image_url,
  image_source_url=excluded.image_source_url,
  image_license=excluded.image_license,
  club=coalesce(excluded.club,'Corinthians'),
  metadata=excluded.metadata;
