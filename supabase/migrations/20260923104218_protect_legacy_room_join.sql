create or replace function public.fa_join_room(
  p_code text,
  p_display_name text
)
returns table(room_id uuid,member_id uuid,budget integer,mode text)
language plpgsql
security definer
set search_path=''
as $function$
begin
  return query
  select j.room_id,j.member_id,j.budget,j.mode
  from public.fa_join_room_v2(
    p_code,
    p_display_name,
    null,
    false
  ) j;
end;
$function$;

revoke execute on function public.fa_join_room(text,text) from anon, public;
grant execute on function public.fa_join_room(text,text) to authenticated;
