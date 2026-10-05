
create or replace function public.fa_heartbeat_room(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_member uuid;
  v_room_kind text;
  v_host_user_id uuid;
  v_cleanup jsonb;
begin
  if v_user is null then
    raise exception 'authentication required';
  end if;

  update public.fa_room_members
  set last_seen_at=now()
  where room_id=p_room_id
    and user_id=v_user
  returning id into v_member;

  if v_member is null then
    raise exception 'not a room member';
  end if;

  select r.room_kind,r.host_user_id
  into v_room_kind,v_host_user_id
  from public.fa_rooms r
  where r.id=p_room_id;

  if v_room_kind is null then
    raise exception 'room not found';
  end if;

  -- In Impostor FC the creator is the permanent game master.
  -- They intentionally stay outside the player pool, so the generic
  -- "active non-spectator host" failover rule must not replace them.
  if v_room_kind='impostor' then
    return jsonb_build_object(
      'ok',true,
      'member_id',v_member,
      'host_user_id',v_host_user_id
    );
  end if;

  v_cleanup:=private.fa_cleanup_inactive_room(p_room_id);

  return jsonb_build_object(
    'ok',true,
    'member_id',v_member,
    'host_user_id',v_cleanup->>'host_user_id'
  );
end;
$function$;

revoke all on function public.fa_heartbeat_room(uuid) from public,anon;
grant execute on function public.fa_heartbeat_room(uuid) to authenticated;

-- Repair Impostor FC rooms affected by the old generic host failover.
-- The room creator is the first membership row created with the room
-- and is intentionally marked as spectator so they are excluded from gameplay.
with original_admin as (
  select distinct on (m.room_id)
    m.room_id,
    m.id as member_id,
    m.user_id
  from public.fa_room_members m
  join public.fa_rooms r on r.id=m.room_id
  where r.room_kind='impostor'
    and m.kicked_at is null
    and m.is_spectator
    and m.joined_at <= r.created_at + interval '2 seconds'
  order by m.room_id,m.joined_at,m.id
),
fixed as (
  update public.fa_rooms r
  set host_user_id=o.user_id
  from original_admin o
  where r.id=o.room_id
    and r.room_kind='impostor'
    and r.host_user_id is distinct from o.user_id
  returning r.id
)
update public.fa_room_members m
set is_host=(m.id=o.member_id)
from original_admin o
where m.room_id=o.room_id
  and (
    m.is_host is distinct from (m.id=o.member_id)
    or m.room_id in (select id from fixed)
  );
