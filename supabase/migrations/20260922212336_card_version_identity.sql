-- Distinguish versions by catalog identity, not display name. Existing data is retained.
drop index public.fa_players_room_name_unique;
create unique index fa_players_room_custom_name_unique on public.fa_players(room_id,lower(trim(name))) where catalog_id is null;
create unique index fa_players_room_catalog_unique on public.fa_players(room_id,catalog_id) where catalog_id is not null;
update public.fa_catalog_players set canonical_key='person:cristiano-ronaldo:portugal' where id='icon_cristiano_ronaldo_2017';
