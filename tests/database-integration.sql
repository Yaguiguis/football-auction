-- Run as postgres in a transaction. Synthetic users, rooms and matches are rolled back.
begin;
do $$
declare u1 uuid:=extensions.gen_random_uuid(); u2 uuid:=extensions.gen_random_uuid(); outsider uuid:=extensions.gen_random_uuid(); r record; r2 record; m1 uuid; m2 uuid; x uuid; res jsonb; saved jsonb; a jsonb; auction_id uuid; slot text; member uuid; uid uuid; pid text; cid text; denied boolean; n integer;
begin
 insert into auth.users(id) values(u1),(u2),(outsider);
 perform set_config('request.jwt.claim.sub',u1::text,true);
 select * into r from public.fa_create_room_v3('X1 TEST A','futsal',100,0,true,1,100,false,null,'skip',true,null,true,true);
 m1:=r.member_id;
 res:=public.fa_room_catalog_summary(r.room_id);
 if coalesce((res->>'total')::int,0)<=0
    or coalesce((res->>'base')::int,0)<=0
    or coalesce((res->>'icons')::int,0)<=0
    or coalesce((res->>'specials')::int,0)<=0
 then raise exception 'room catalog summary mismatch';end if;
 perform set_config('request.jwt.claim.sub',u2::text,true);
 perform public.fa_join_room_v2(r.room_code,'X1 TEST B',null,false);
 select id into m2 from public.fa_room_members where room_id=r.room_id and user_id=u2;
 -- Check three independent type gates and the legacy active-only override.
 update public.fa_rooms set allow_base=false,allow_icons=false where id=r.room_id;
 if private.fa_catalog_allowed_for_room(r.room_id,'icon-pele') or private.fa_catalog_allowed_for_room(r.room_id,'pl-salah') or not private.fa_catalog_allowed_for_room(r.room_id,'cristiano-ronaldo-2008-special') then raise exception 'type filter mismatch';end if;
 update public.fa_rooms set active_only=true where id=r.room_id;
 if private.fa_catalog_allowed_for_room(r.room_id,'cristiano-ronaldo-2008-special') then raise exception 'legacy active-only mismatch';end if;
 update public.fa_rooms set active_only=false,allowed_leagues=array['Premier League'] where id=r.room_id;
 if private.fa_catalog_allowed_for_room(r.room_id,'lionel-messi-2012-special') then raise exception 'league filter mismatch';end if;
 update public.fa_rooms set allowed_leagues=null where id=r.room_id;
 -- Actual draw/QUERO/PASSAR, then sequential bid/withdrawal with SPECIAL only.
 perform set_config('request.jwt.claim.sub',u1::text,true);
 perform public.fa_set_ready(r.room_id,true);
 perform set_config('request.jwt.claim.sub',u2::text,true);
 perform public.fa_set_ready(r.room_id,true);
 perform set_config('request.jwt.claim.sub',u1::text,true);
 a:=public.fa_begin_auction(r.room_id);auction_id:=(a->>'id')::uuid;
 if not exists(select 1 from public.fa_players p join public.fa_auctions a on a.player_id=p.id where a.id=auction_id and p.player_type='SPECIAL' and p.metadata->>'version_label' is not null and a.ends_at is null) then raise exception 'SPECIAL draw/snapshot failed';end if;
 perform public.fa_set_interest(auction_id,true);
 perform set_config('request.jwt.claim.sub',u2::text,true);
 perform public.fa_set_interest(auction_id,false);
 if not exists(select 1 from public.fa_auctions where id=auction_id and status='sold' and winner_member_id=m1) then raise exception 'QUERO/PASSAR failed';end if;
 perform set_config('request.jwt.claim.sub',u1::text,true);
 a:=public.fa_start_next_auction(r.room_id);auction_id:=(a->>'id')::uuid;
 perform public.fa_set_interest(auction_id,true);
 perform set_config('request.jwt.claim.sub',u2::text,true);
 perform public.fa_set_interest(auction_id,true);
 select m.user_id into uid from public.fa_auctions a join public.fa_room_members m on m.id=a.turn_member_id where a.id=auction_id;
 perform set_config('request.jwt.claim.sub',uid::text,true);
 perform public.fa_place_bid(auction_id,1);
 select m.user_id into uid from public.fa_auctions a join public.fa_room_members m on m.id=a.turn_member_id where a.id=auction_id;
 perform set_config('request.jwt.claim.sub',uid::text,true);
 perform public.fa_withdraw_bid(auction_id);
 if not exists(select 1 from public.fa_auctions where id=auction_id and status='sold' and ends_at is null and final_price=1) then raise exception 'sequential bid/withdraw failed';end if;
 perform public.fa_send_room_message(r.room_id,'Teste de chat transacional');
 -- Separate room for finalized lineups and X1; test data never reaches live sessions.
 perform set_config('request.jwt.claim.sub',u1::text,true);
 select * into r2 from public.fa_create_room_v3('Time A','futsal',100,0,true,1,100,false,null,'skip',true,null,true,true);
 m1:=r2.member_id;
 perform set_config('request.jwt.claim.sub',u2::text,true);
 perform public.fa_join_room_v2(r2.room_code,'Time B',null,false);
 select id into m2 from public.fa_room_members where room_id=r2.room_id and user_id=u2;
 foreach member in array array[m1,m2] loop
  foreach slot in array array['GOL','FIXO','ALAE','ALAD','PIVO'] loop
   cid:=case slot when 'GOL' then 'icon-buffon' when 'FIXO' then 'icon-maldini' when 'ALAE' then 'cristiano-ronaldo-2008-special' when 'ALAD' then 'neymar-2020-special' else 'lionel-messi-2012-special' end;
   if member=m2 then cid:=case slot when 'GOL' then 'icon-lev-yashin' when 'FIXO' then 'icon-franco-baresi' when 'ALAE' then 'cristiano-ronaldo-2014-special' when 'ALAD' then 'neymar-2015-special' else 'lionel-messi-2015-special' end;end if;
   pid:=extensions.gen_random_uuid()::text;
   insert into public.fa_players(id,room_id,created_by,catalog_id,name,primary_position,secondary_positions,overall,player_type,image_url,metadata)
   select pid,r2.room_id,u1,id,name,primary_position,secondary_positions,overall,player_type,image_url,metadata from public.fa_catalog_players where id=cid;
   insert into public.fa_squad_players(member_id,player_id,slot_key,is_bench) values(member,pid,slot,false);
  end loop;
 end loop;
 update public.fa_rooms set status='auction' where id=r2.room_id;
 perform set_config('request.jwt.claim.sub',u1::text,true); perform public.fa_finalize_squad(r2.room_id);
 perform set_config('request.jwt.claim.sub',u2::text,true); perform public.fa_finalize_squad(r2.room_id);
 perform set_config('request.jwt.claim.sub',u1::text,true);
 x:=public.fa_challenge_x1(r2.room_id,m2);
 -- Challenger cannot answer own challenge.
 denied:=false;begin perform public.fa_respond_x1(x,true);exception when others then denied:=true;end;
 if not denied then raise exception 'challenger accepted own match';end if;
 perform set_config('request.jwt.claim.sub',outsider::text,true);
 denied:=false;begin perform public.fa_respond_x1(x,true);exception when others then denied:=true;end;
 if not denied then raise exception 'outsider accepted match';end if;
 execute 'set local role authenticated';
 select count(*) into n from public.fa_x1_matches where id=x;
 if n<>0 then raise exception 'outsider RLS leak';end if;
 execute 'reset role';
 perform set_config('request.jwt.claim.sub',u2::text,true);
 execute 'set local role authenticated';
 res:=public.fa_respond_x1(x,true);
 execute 'reset role';
 if res->>'status'<>'completed' then raise exception 'match not completed';end if;
 saved:=res->'result';
 if saved<>private.fa_simulate_match_v1(res->'team_a',res->'team_b',(res->>'seed')::bigint) then raise exception 'seed replay mismatch';end if;
 if (public.fa_respond_x1(x,true))->'result'<>saved then raise exception 'retry rerolled match';end if;
 execute 'set local role authenticated';
 select count(*) into n from public.fa_x1_matches where id=x;
 if n<>1 then raise exception 'member cannot read match';end if;
 denied:=false;begin update public.fa_x1_matches set result='{}' where id=x;exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'client can tamper with result';end if;
 execute 'reset role';
 -- Reverse challenger can decline, then replay archives the round and retains X1.
 perform set_config('request.jwt.claim.sub',u2::text,true);
 x:=public.fa_challenge_x1(r2.room_id,m1);
 perform set_config('request.jwt.claim.sub',u1::text,true);
 if public.fa_respond_x1(x,false)->>'status'<>'declined' then raise exception 'decline failed';end if;
 perform public.fa_request_replay(r2.room_id);
 if not exists(select 1 from public.fa_round_archives where room_id=r2.room_id) or not exists(select 1 from public.fa_x1_matches where room_id=r2.room_id and status='completed' and result=saved) then raise exception 'replay lost history';end if;
 if exists(select 1 from public.fa_squad_players where member_id in(m1,m2)) then raise exception 'replay did not reset live squads';end if;
 -- Identity/version uniqueness: same canonical person cannot be inserted twice as BASE.
 denied:=false;begin
  insert into public.fa_catalog_players(id,name,league,nationality,primary_position,player_type,overall,canonical_key,slug) select 'test-duplicate','different spelling',league,nationality,primary_position,player_type,overall,canonical_key,'test-duplicate' from public.fa_catalog_players where id='ea27_vinicius';
 exception when unique_violation then denied:=true;end;
 if not denied then raise exception 'canonical duplicate was accepted';end if;
end $$;
select 'PASS: room catalog summary, filters, SPECIAL draw, QUERO/PASSAR, sequential bidding, withdrawal, chat, finalization, X1 accept/decline, seed replay, RLS, tamper rejection, replay archive, deduplication' as result;
rollback;
