create or replace function public.fa_room_catalog_summary(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_total integer;
  v_base integer;
  v_icons integer;
  v_specials integer;
begin
  if v_user is null then
    raise exception 'authentication required';
  end if;

  if not exists(
    select 1
    from public.fa_room_members m
    where m.room_id=p_room_id
      and m.user_id=v_user
      and m.kicked_at is null
  ) then
    raise exception 'not a room member';
  end if;

  select
    count(*) filter (where private.fa_catalog_allowed_for_room(p_room_id,c.id)),
    count(*) filter (
      where c.player_type='ACTIVE'
        and private.fa_catalog_allowed_for_room(p_room_id,c.id)
    ),
    count(*) filter (
      where c.player_type='ICON'
        and private.fa_catalog_allowed_for_room(p_room_id,c.id)
    ),
    count(*) filter (
      where c.player_type='SPECIAL'
        and private.fa_catalog_allowed_for_room(p_room_id,c.id)
    )
  into v_total,v_base,v_icons,v_specials
  from public.fa_catalog_players c
  where c.enabled=true;

  return jsonb_build_object(
    'total',coalesce(v_total,0),
    'base',coalesce(v_base,0),
    'icons',coalesce(v_icons,0),
    'specials',coalesce(v_specials,0)
  );
end;
$function$;

revoke all on function public.fa_room_catalog_summary(uuid) from public;
grant execute on function public.fa_room_catalog_summary(uuid) to authenticated;
