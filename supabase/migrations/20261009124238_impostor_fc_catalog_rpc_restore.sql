create or replace function public.fa_impostor_catalog(
  p_room_id uuid,
  p_search text default null
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_search text:=trim(coalesce(p_search,''));
  v_is_spectator boolean;
begin
  if v_user is null then
    raise exception 'authentication required';
  end if;

  select m.is_spectator
  into v_is_spectator
  from public.fa_rooms r
  join public.fa_room_members m
    on m.room_id=r.id
   and m.user_id=v_user
   and m.kicked_at is null
  where r.id=p_room_id
    and r.room_kind='impostor'
    and r.host_user_id=v_user;

  if not found or not coalesce(v_is_spectator,false) then
    raise exception 'only a watching administrator can browse the secret-player catalog';
  end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'id',x.id,
        'name',x.name,
        'club',x.club,
        'league',x.league,
        'nationality',x.nationality,
        'primary_position',x.primary_position,
        'overall',x.overall,
        'player_type',x.player_type,
        'image_url',x.image_url
      )
      order by x.overall desc,x.name
    )
    from (
      select c.*
      from public.fa_catalog_players c
      where c.enabled
        and coalesce(c.metadata->>'source','')<>'impostor_custom'
        and private.fa_catalog_allowed_for_room(p_room_id,c.id)
        and (
          v_search=''
          or lower(c.name) like '%'||lower(v_search)||'%'
          or lower(coalesce(c.club,'')) like '%'||lower(v_search)||'%'
          or lower(coalesce(c.nationality,'')) like '%'||lower(v_search)||'%'
          or lower(coalesce(c.league,'')) like '%'||lower(v_search)||'%'
          or lower(coalesce(c.primary_position,'')) like '%'||lower(v_search)||'%'
        )
      order by c.overall desc,c.name
      limit 100
    ) x
  ),'[]'::jsonb);
end;
$function$;

revoke all on function public.fa_impostor_catalog(uuid,text) from public,anon;
grant execute on function public.fa_impostor_catalog(uuid,text) to authenticated;
