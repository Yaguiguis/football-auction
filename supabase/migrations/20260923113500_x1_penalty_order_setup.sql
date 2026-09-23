create or replace function public.fa_respond_x1(p_match_id uuid,p_accept boolean)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_a jsonb;
  v_b jsonb;
  v_seed bigint;
  v_result jsonb;
  v_status text;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  select * into v_me from public.fa_room_members where room_id=v_match.room_id and user_id=v_user and kicked_at is null;
  if not found or v_me.id<>v_match.opponent_id then raise exception 'only challenged player can respond'; end if;
  if v_match.status<>'pending' then return to_jsonb(v_match); end if;

  if not p_accept then
    update public.fa_x1_matches set status='declined',responded_at=now() where id=v_match.id returning * into v_match;
    return to_jsonb(v_match);
  end if;

  v_a:=private.fa_x1_snapshot(v_match.challenger_id);
  v_b:=private.fa_x1_snapshot(v_match.opponent_id);
  v_seed:=(('x'||encode(extensions.gen_random_bytes(4),'hex'))::bit(32)::bigint % 2147483646)+1;
  v_result:=private.fa_simulate_knockout_match_v2(v_a,v_b,v_seed,false);
  v_status:=case when v_result->>'decided_by'='penalties' and v_result->>'winner' is null then 'shootout' else 'completed' end;

  if v_status='shootout' then
    v_result:=jsonb_set(v_result,'{penalty_shootout}',jsonb_build_object(
      'score',jsonb_build_object('a',0,'b',0),
      'kicks','[]'::jsonb,
      'status','setup',
      'orders',jsonb_build_object('a','[]'::jsonb,'b','[]'::jsonb),
      'ready',jsonb_build_object('a',false,'b',false)
    ),true);
  end if;

  update public.fa_x1_matches
  set status=v_status,team_a=v_a,team_b=v_b,result=v_result,seed=v_seed,responded_at=now(),completed_at=case when v_status='completed' then now() else null end
  where id=v_match.id
  returning * into v_match;
  return to_jsonb(v_match);
end;
$function$;

create or replace function public.fa_set_x1_penalty_order(p_match_id uuid,p_player_ids uuid[])
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_team text;
  v_players jsonb;
  v_order jsonb:='[]'::jsonb;
  v_id uuid;
  v_player jsonb;
  v_count integer:=0;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  if v_match.status<>'shootout' or coalesce(v_match.result#>>'{penalty_shootout,status}','')<>'setup' then return to_jsonb(v_match); end if;

  select * into v_me from public.fa_room_members
  where room_id=v_match.room_id and user_id=v_user and kicked_at is null and not is_spectator;
  if not found then raise exception 'player not found'; end if;
  if v_me.id=v_match.challenger_id then v_team:='a'; v_players:=v_match.team_a->'players';
  elsif v_me.id=v_match.opponent_id then v_team:='b'; v_players:=v_match.team_b->'players';
  else raise exception 'not a match player'; end if;

  if p_player_ids is null or cardinality(p_player_ids)<5 then raise exception 'choose at least five kickers'; end if;
  if (select count(distinct x) from unnest(p_player_ids) x)<>cardinality(p_player_ids) then raise exception 'duplicate kicker'; end if;

  foreach v_id in array p_player_ids loop
    select value into v_player
    from jsonb_array_elements(v_players)
    where value->>'id'=v_id::text and coalesce(value->>'slot','') not like 'BENCH%'
    limit 1;
    if v_player is null then raise exception 'invalid kicker'; end if;
    v_order:=v_order||jsonb_build_array(jsonb_build_object('id',v_player->>'id','name',v_player->>'name'));
    v_count:=v_count+1;
    v_player:=null;
  end loop;
  if v_count<5 then raise exception 'choose at least five kickers'; end if;

  update public.fa_x1_matches
  set result=jsonb_set(
    jsonb_set(result,array['penalty_shootout','orders',v_team],v_order,true),
    array['penalty_shootout','ready',v_team],
    'true'::jsonb,
    true
  )
  where id=v_match.id
  returning * into v_match;
  return to_jsonb(v_match);
end;
$function$;

create or replace function public.fa_start_x1_penalties(p_match_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_team text;
  v_order jsonb;
  v_player text;
  v_result jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  if v_match.status<>'shootout' or coalesce(v_match.result#>>'{penalty_shootout,status}','')<>'setup' then return to_jsonb(v_match); end if;

  select * into v_me from public.fa_room_members
  where room_id=v_match.room_id and user_id=v_user and kicked_at is null and not is_spectator;
  if not found then raise exception 'player not found'; end if;
  if v_me.id=v_match.challenger_id then v_team:='a';
  elsif v_me.id=v_match.opponent_id then v_team:='b';
  else raise exception 'not a match player'; end if;

  v_order:=v_match.result#>(array['penalty_shootout','orders',v_team]);
  if v_order is null or jsonb_array_length(v_order)<5 then raise exception 'confirm kicker order first'; end if;

  v_result:=jsonb_set(v_match.result,array['penalty_shootout','ready',v_team],'true'::jsonb,true);
  if coalesce((v_result#>>'{penalty_shootout,ready,a}')::boolean,false) and coalesce((v_result#>>'{penalty_shootout,ready,b}')::boolean,false) then
    v_player:=coalesce(v_result#>>'{penalty_shootout,orders,a,0,name}',v_match.team_a->>'name');
    v_result:=jsonb_set(v_result,'{penalty_shootout}',(v_result->'penalty_shootout')||jsonb_build_object(
      'status','pending',
      'next',jsonb_build_object('index',1,'team','a','suddenDeath',false,'player',v_player)
    ),true);
  end if;

  update public.fa_x1_matches set result=v_result where id=v_match.id returning * into v_match;
  return to_jsonb(v_match);
end;
$function$;

create or replace function public.fa_choose_x1_penalty(p_match_id uuid,p_direction text)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_next jsonb;
  v_team text;
  v_kick_no integer;
  v_role text;
  v_shooter uuid;
  v_keeper uuid;
  v_shot text;
  v_keep text;
  v_goal boolean;
  v_kicks jsonb;
  v_score_a integer;
  v_score_b integer;
  v_taken_a integer;
  v_taken_b integer;
  v_remaining_a integer;
  v_remaining_b integer;
  v_complete boolean:=false;
  v_winner text;
  v_next_team text;
  v_next_taken integer;
  v_next_order_len integer;
  v_next_player text;
  v_result jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if p_direction not in ('left','center','right') then raise exception 'invalid penalty direction'; end if;

  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  if v_match.status<>'shootout' then return to_jsonb(v_match); end if;
  if coalesce(v_match.result#>>'{penalty_shootout,status}','')<>'pending' then raise exception 'penalty order is not ready'; end if;

  select * into v_me from public.fa_room_members
  where room_id=v_match.room_id and user_id=v_user and kicked_at is null and not is_spectator;
  if not found then raise exception 'player not found'; end if;

  v_next:=v_match.result#>'{penalty_shootout,next}';
  if v_next is null then raise exception 'shootout is not accepting choices'; end if;
  v_team:=v_next->>'team';
  v_kick_no:=coalesce((v_next->>'index')::integer,1);

  if v_team='a' then v_shooter:=v_match.challenger_id; v_keeper:=v_match.opponent_id;
  else v_shooter:=v_match.opponent_id; v_keeper:=v_match.challenger_id; end if;

  if v_me.id=v_shooter then v_role:='shot';
  elsif v_me.id=v_keeper then v_role:='keeper';
  else raise exception 'not a match player'; end if;

  insert into private.fa_x1_penalty_choices(match_id,kick_no,role,member_id,direction)
  values(v_match.id,v_kick_no,v_role,v_me.id,p_direction)
  on conflict(match_id,kick_no,role) do update
    set member_id=excluded.member_id,direction=excluded.direction,created_at=now();

  select max(direction) filter (where role='shot'), max(direction) filter (where role='keeper')
  into v_shot,v_keep
  from private.fa_x1_penalty_choices
  where match_id=v_match.id and kick_no=v_kick_no;

  if v_shot is null or v_keep is null then
    select * into v_match from public.fa_x1_matches where id=p_match_id;
    return to_jsonb(v_match);
  end if;

  v_goal:=v_shot<>v_keep;
  v_score_a:=coalesce((v_match.result#>>'{penalty_shootout,score,a}')::integer,0);
  v_score_b:=coalesce((v_match.result#>>'{penalty_shootout,score,b}')::integer,0);
  if v_team='a' and v_goal then v_score_a:=v_score_a+1; end if;
  if v_team='b' and v_goal then v_score_b:=v_score_b+1; end if;

  v_kicks:=coalesce(v_match.result#>'{penalty_shootout,kicks}','[]'::jsonb)
    ||jsonb_build_array(jsonb_build_object('index',v_kick_no,'team',v_team,'shot',v_shot,'keeper',v_keep,'goal',v_goal,'player',v_next->>'player'));

  select count(*) filter (where value->>'team'='a'), count(*) filter (where value->>'team'='b')
  into v_taken_a,v_taken_b
  from jsonb_array_elements(v_kicks);

  v_remaining_a:=greatest(0,5-v_taken_a);
  v_remaining_b:=greatest(0,5-v_taken_b);
  if (v_taken_a<=5 and v_taken_b<=5 and (v_score_a>v_score_b+v_remaining_b or v_score_b>v_score_a+v_remaining_a))
    or (v_taken_a>=5 and v_taken_b>=5 and v_taken_a=v_taken_b and v_score_a<>v_score_b) then
    v_complete:=true;
    v_winner:=case when v_score_a>v_score_b then v_match.challenger_id::text else v_match.opponent_id::text end;
  end if;

  if v_complete then
    v_result:=jsonb_set(v_match.result,'{winner}',to_jsonb(v_winner),true);
    v_result:=jsonb_set(v_result,'{penalties}',jsonb_build_object('a',v_score_a,'b',v_score_b),true);
    v_result:=jsonb_set(v_result,'{penalty_shootout}',(v_result->'penalty_shootout')||jsonb_build_object('score',jsonb_build_object('a',v_score_a,'b',v_score_b),'kicks',v_kicks,'status','completed'),true);
    update public.fa_x1_matches set status='completed',result=v_result,completed_at=now() where id=v_match.id returning * into v_match;
    delete from private.fa_x1_penalty_choices where match_id=v_match.id;
    return to_jsonb(v_match);
  end if;

  v_next_team:=case when v_team='a' then 'b' else 'a' end;
  v_next_taken:=case when v_next_team='a' then v_taken_a else v_taken_b end;
  v_next_order_len:=greatest(1,jsonb_array_length(coalesce(v_match.result#>(array['penalty_shootout','orders',v_next_team]),'[]'::jsonb)));
  v_next_player:=coalesce(v_match.result#>>(array['penalty_shootout','orders',v_next_team,(v_next_taken % v_next_order_len)::text,'name']),case when v_next_team='a' then v_match.team_a->>'name' else v_match.team_b->>'name' end);

  v_result:=jsonb_set(v_match.result,'{penalties}',jsonb_build_object('a',v_score_a,'b',v_score_b),true);
  v_result:=jsonb_set(v_result,'{penalty_shootout}',(v_result->'penalty_shootout')||jsonb_build_object(
    'score',jsonb_build_object('a',v_score_a,'b',v_score_b),
    'kicks',v_kicks,
    'status','pending',
    'next',jsonb_build_object('index',v_kick_no+1,'team',v_next_team,'suddenDeath',(v_taken_a>=5 and v_taken_b>=5),'player',v_next_player)
  ),true);

  update public.fa_x1_matches set result=v_result where id=v_match.id returning * into v_match;
  delete from private.fa_x1_penalty_choices where match_id=v_match.id and kick_no=v_kick_no;
  return to_jsonb(v_match);
end;
$function$;

revoke all on function public.fa_set_x1_penalty_order(uuid,uuid[]), public.fa_start_x1_penalties(uuid) from public,anon;
grant execute on function public.fa_set_x1_penalty_order(uuid,uuid[]), public.fa_start_x1_penalties(uuid) to authenticated;
