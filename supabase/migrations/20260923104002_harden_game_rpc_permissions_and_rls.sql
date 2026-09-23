revoke execute on function public.fa_begin_auction(uuid) from anon, public;
revoke execute on function public.fa_create_room_v2(text,text,integer,integer,boolean,integer,integer,boolean,text[],text,boolean,text) from anon, public;
revoke execute on function public.fa_create_tournament_room(text,text,integer,integer,integer,boolean,integer,integer,text[],text,boolean,text,boolean,boolean) from anon, public;
revoke execute on function public.fa_delete_room_message(uuid) from anon, public;
revoke execute on function public.fa_heartbeat_room(uuid) from anon, public;
revoke execute on function public.fa_join_room_v2(text,text,text,boolean) from anon, public;
revoke execute on function public.fa_kick_member(uuid) from anon, public;
revoke execute on function public.fa_play_tournament_round(uuid) from anon, public;
revoke execute on function public.fa_room_catalog_summary(uuid) from anon, public;
revoke execute on function public.fa_send_room_message(uuid,text) from anon, public;
revoke execute on function public.fa_set_ready(uuid,boolean) from anon, public;
revoke execute on function public.fa_set_room_mode(uuid,text) from anon, public;

grant execute on function public.fa_begin_auction(uuid) to authenticated;
grant execute on function public.fa_create_room_v2(text,text,integer,integer,boolean,integer,integer,boolean,text[],text,boolean,text) to authenticated;
grant execute on function public.fa_create_tournament_room(text,text,integer,integer,integer,boolean,integer,integer,text[],text,boolean,text,boolean,boolean) to authenticated;
grant execute on function public.fa_delete_room_message(uuid) to authenticated;
grant execute on function public.fa_heartbeat_room(uuid) to authenticated;
grant execute on function public.fa_join_room_v2(text,text,text,boolean) to authenticated;
grant execute on function public.fa_kick_member(uuid) to authenticated;
grant execute on function public.fa_play_tournament_round(uuid) to authenticated;
grant execute on function public.fa_room_catalog_summary(uuid) to authenticated;
grant execute on function public.fa_send_room_message(uuid,text) to authenticated;
grant execute on function public.fa_set_ready(uuid,boolean) to authenticated;
grant execute on function public.fa_set_room_mode(uuid,text) to authenticated;

drop policy if exists fa_room_messages_select_members on public.fa_room_messages;
create policy fa_room_messages_select_members
on public.fa_room_messages
for select
to authenticated
using (
  exists (
    select 1
    from public.fa_room_members m
    where m.room_id=fa_room_messages.room_id
      and m.user_id=(select auth.uid())
      and m.kicked_at is null
  )
);

drop policy if exists fa_tournament_matches_select_members on public.fa_tournament_matches;
create policy fa_tournament_matches_select_members
on public.fa_tournament_matches
for select
to authenticated
using (
  exists (
    select 1
    from public.fa_room_members m
    where m.room_id=fa_tournament_matches.room_id
      and m.user_id=(select auth.uid())
      and m.kicked_at is null
  )
);
