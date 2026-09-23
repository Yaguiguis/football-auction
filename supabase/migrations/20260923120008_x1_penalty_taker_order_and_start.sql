create table if not exists private.fa_x1_penalty_orders (
  match_id uuid not null references public.fa_x1_matches(id) on delete cascade,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  player_ids text[] not null,
  confirmed boolean not null default true,
  updated_at timestamptz not null default now(),
  primary key(match_id,member_id),
  constraint fa_x1_penalty_orders_five_players check (cardinality(player_ids)=5)
);

update public.fa_x1_matches
set result=jsonb_set(
  result,
  '{penalty_shootout}',
  ((result->'penalty_shootout')-'next')
    ||jsonb_build_object(
      'status','setup',
      'setup',jsonb_build_object('status','selecting')
    ),
  true
)
where status='shootout'
  and coalesce(jsonb_array_length(result#>'{penalty_shootout,kicks}'),0)=0;

create or replace function public.fa_get_x1_penalty_setup(p_match_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_a_order text[];
  v_b_order text[];
  v_my_order text[];
  v_a_ready boolean:=false;
  v_b_ready boolean:=false;
  v_status text;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_match from public.fa_x1_matches where id=p_match_id;
  if not found then raise exception 'match not found'; end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_match.room_id and user_id=v_user and kicked_at is null
  limit 1;
  if not found then raise exception 'not a room member'; end if;

  select player_ids into v_a_order
  from private.fa_x1_penalty_orders
  where match_id=p_match_id and member_id=v_match.challenger_id and confirmed;

  select player_ids into v_b_order
  from private.fa_x1_penalty_orders
  where match_id=p_match_id and member_id=v_match.opponent_id and confirmed;

  v_a_ready:=v_a_order is not null;
  v_b_ready:=v_b_order is not null;
  v_status:=coalesce(v_match.result#>>'{penalty_shootout,setup,status}','selecting');

  if v_me.id=v_match.challenger_id then
    v_my_order:=v_a_order;
  elsif v_me.id=v_match.opponent_id then
    v_my_order:=v_b_order;
  end if;

  return jsonb_build_object(
    'status',v_status,
    'a_ready',v_a_ready,
    'b_ready',v_b_ready,
    'both_ready',v_a_ready and v_b_ready,
    'can_start',(v_me.id in(v_match.challenger_id,v_match.opponent_id))
      and v_a_ready and v_b_ready and v_status='selecting',
    'my_order',coalesce(to_jsonb(v_my_order),'[]'::jsonb)
  );
end;
$function$;

create or replace function public.fa_set_x1_penalty_order(
  p_match_id uuid,
  p_player_ids text[]
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_match public.fa_x1_matches%rowtype;
  v_me public.fa_room_members%rowtype;
  v_team jsonb;
  v_count integer;
  v_unique integer;
  v_valid integer;
  v_status text;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  if v_match.status<>'shootout' then raise exception 'match is not in a shootout'; end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_match.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator
  limit 1;

  if not found then raise exception 'player not found'; end if;
  if v_me.id not in(v_match.challenger_id,v_match.opponent_id) then
    raise exception 'not a match player';
  end if;

  v_status:=coalesce(v_match.result#>>'{penalty_shootout,setup,status}','selecting');
  if v_status<>'selecting' then raise exception 'penalty order is already locked'; end if;

  v_count:=coalesce(cardinality(p_player_ids),0);
  if v_count<>5 then raise exception 'choose exactly five penalty takers'; end if;

  select count(distinct x) into v_unique from unnest(p_player_ids) x;
  if v_unique<>5 then raise exception 'penalty takers must be unique'; end if;

  v_team:=case when v_me.id=v_match.challenger_id then v_match.team_a else v_match.team_b end;
  if v_team is null then raise exception 'team snapshot is missing'; end if;

  select count(*) into v_valid
  from unnest(p_player_ids) chosen(player_id)
  where exists(
    select 1
    from jsonb_array_elements(v_team->'players') p
    where p->>'id'=chosen.player_id
  );

  if v_valid<>5 then raise exception 'invalid penalty taker'; end if;

  insert into private.fa_x1_penalty_orders(match_id,member_id,player_ids,confirmed,updated_at)
  values(p_match_id,v_me.id,p_player_ids,true,now())
  on conflict(match_id,member_id) do update
    set player_ids=excluded.player_ids,
        confirmed=true,
        updated_at=now();

  return public.fa_get_x1_penalty_setup(p_match_id);
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
  v_a_order text[];
  v_b_order text[];
  v_shootout jsonb;
  v_result jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  if v_match.status<>'shootout' then raise exception 'match is not in a shootout'; end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_match.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator
  limit 1;

  if not found or v_me.id not in(v_match.challenger_id,v_match.opponent_id) then
    raise exception 'not a match player';
  end if;

  if coalesce(v_match.result#>>'{penalty_shootout,setup,status}','selecting')<>'selecting' then
    return to_jsonb(v_match);
  end if;

  select player_ids into v_a_order
  from private.fa_x1_penalty_orders
  where match_id=p_match_id and member_id=v_match.challenger_id and confirmed;

  select player_ids into v_b_order
  from private.fa_x1_penalty_orders
  where match_id=p_match_id and member_id=v_match.opponent_id and confirmed;

  if v_a_order is null or v_b_order is null then
    raise exception 'both players must confirm their penalty order first';
  end if;

  v_shootout:=coalesce(v_match.result->'penalty_shootout','{}'::jsonb);
  v_shootout:=(v_shootout-'next')
    ||jsonb_build_object(
      'score',coalesce(v_shootout->'score',jsonb_build_object('a',0,'b',0)),
      'kicks',coalesce(v_shootout->'kicks','[]'::jsonb),
      'status','pending',
      'setup',jsonb_build_object(
        'status','started',
        'order_a',to_jsonb(v_a_order),
        'order_b',to_jsonb(v_b_order)
      ),
      'next',jsonb_build_object('index',1,'team','a','suddenDeath',false)
    );

  v_result:=jsonb_set(v_match.result,'{penalty_shootout}',v_shootout,true);

  update public.fa_x1_matches
  set result=v_result
  where id=p_match_id
  returning * into v_match;

  return to_jsonb(v_match);
end;
$function$;

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
  v_shootout jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_match.room_id and user_id=v_user and kicked_at is null;

  if not found or v_me.id<>v_match.opponent_id then
    raise exception 'only challenged player can respond';
  end if;

  if v_match.status<>'pending' then return to_jsonb(v_match); end if;

  if not p_accept then
    update public.fa_x1_matches
    set status='declined',responded_at=now()
    where id=v_match.id
    returning * into v_match;
    return to_jsonb(v_match);
  end if;

  v_a:=private.fa_x1_snapshot(v_match.challenger_id);
  v_b:=private.fa_x1_snapshot(v_match.opponent_id);
  v_seed:=(('x'||encode(extensions.gen_random_bytes(4),'hex'))::bit(32)::bigint % 2147483646)+1;
  v_result:=private.fa_simulate_knockout_match_v2(v_a,v_b,v_seed,false);
  v_status:=case
    when v_result->>'decided_by'='penalties' and v_result->>'winner' is null then 'shootout'
    else 'completed'
  end;

  if v_status='shootout' then
    v_shootout:=coalesce(v_result->'penalty_shootout','{}'::jsonb);
    v_shootout:=(v_shootout-'next')
      ||jsonb_build_object(
        'score',coalesce(v_shootout->'score',jsonb_build_object('a',0,'b',0)),
        'kicks',coalesce(v_shootout->'kicks','[]'::jsonb),
        'status','setup',
        'setup',jsonb_build_object('status','selecting')
      );
    v_result:=jsonb_set(v_result,'{penalty_shootout}',v_shootout,true);
  end if;

  update public.fa_x1_matches
  set status=v_status,
      team_a=v_a,
      team_b=v_b,
      result=v_result,
      seed=v_seed,
      responded_at=now(),
      completed_at=case when v_status='completed' then now() else null end
  where id=v_match.id
  returning * into v_match;

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
  v_result jsonb;
  v_setup_status text;
  v_order text[];
  v_side_kick integer;
  v_kicker_id text;
  v_kicker_name text;
  v_team_snapshot jsonb;
begin
  if v_user is null then raise exception 'authentication required'; end if;
  if p_direction not in ('left','center','right') then raise exception 'invalid penalty direction'; end if;

  select * into v_match from public.fa_x1_matches where id=p_match_id for update;
  if not found then raise exception 'match not found'; end if;
  if v_match.status<>'shootout' then return to_jsonb(v_match); end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_match.room_id
    and user_id=v_user
    and kicked_at is null
    and not is_spectator;

  if not found then raise exception 'player not found'; end if;

  v_setup_status:=v_match.result#>>'{penalty_shootout,setup,status}';
  if v_setup_status is not null and v_setup_status<>'started' then
    raise exception 'penalty shootout has not started yet';
  end if;

  v_next:=v_match.result#>'{penalty_shootout,next}';
  if v_next is null then raise exception 'shootout is not accepting choices'; end if;

  v_team:=v_next->>'team';
  v_kick_no:=coalesce((v_next->>'index')::integer,1);

  if v_team='a' then
    v_shooter:=v_match.challenger_id;
    v_keeper:=v_match.opponent_id;
  else
    v_shooter:=v_match.opponent_id;
    v_keeper:=v_match.challenger_id;
  end if;

  if v_me.id=v_shooter then
    v_role:='shot';
  elsif v_me.id=v_keeper then
    v_role:='keeper';
  else
    raise exception 'not a match player';
  end if;

  insert into private.fa_x1_penalty_choices(match_id,kick_no,role,member_id,direction)
  values(v_match.id,v_kick_no,v_role,v_me.id,p_direction)
  on conflict(match_id,kick_no,role) do update
    set member_id=excluded.member_id,direction=excluded.direction,created_at=now();

  select
    max(direction) filter (where role='shot'),
    max(direction) filter (where role='keeper')
  into v_shot,v_keep
  from private.fa_x1_penalty_choices
  where match_id=v_match.id and kick_no=v_kick_no;

  if v_shot is null or v_keep is null then
    select * into v_match from public.fa_x1_matches where id=p_match_id;
    return to_jsonb(v_match);
  end if;

  if v_setup_status='started' then
    select player_ids into v_order
    from private.fa_x1_penalty_orders
    where match_id=v_match.id and member_id=v_shooter;

    if v_order is null then raise exception 'penalty order is missing'; end if;

    v_side_kick:=case
      when v_team='a' then ((v_kick_no+1)/2)
      else (v_kick_no/2)
    end;

    v_kicker_id:=v_order[((v_side_kick-1)%5)+1];
    v_team_snapshot:=case when v_team='a' then v_match.team_a else v_match.team_b end;

    select p->>'name' into v_kicker_name
    from jsonb_array_elements(v_team_snapshot->'players') p
    where p->>'id'=v_kicker_id
    limit 1;
  end if;

  v_goal:=v_shot<>v_keep;
  v_score_a:=coalesce((v_match.result#>>'{penalty_shootout,score,a}')::integer,0);
  v_score_b:=coalesce((v_match.result#>>'{penalty_shootout,score,b}')::integer,0);

  if v_team='a' and v_goal then v_score_a:=v_score_a+1; end if;
  if v_team='b' and v_goal then v_score_b:=v_score_b+1; end if;

  v_kicks:=coalesce(v_match.result#>'{penalty_shootout,kicks}','[]'::jsonb)
    ||jsonb_build_array(
      jsonb_build_object(
        'index',v_kick_no,
        'team',v_team,
        'shot',v_shot,
        'keeper',v_keep,
        'goal',v_goal,
        'player_id',v_kicker_id,
        'player',v_kicker_name
      )
    );

  select
    count(*) filter (where value->>'team'='a'),
    count(*) filter (where value->>'team'='b')
  into v_taken_a,v_taken_b
  from jsonb_array_elements(v_kicks);

  v_remaining_a:=greatest(0,5-v_taken_a);
  v_remaining_b:=greatest(0,5-v_taken_b);

  if (v_taken_a<=5 and v_taken_b<=5 and
      (v_score_a>v_score_b+v_remaining_b or v_score_b>v_score_a+v_remaining_a))
     or
     (v_taken_a>=5 and v_taken_b>=5 and v_taken_a=v_taken_b and v_score_a<>v_score_b)
  then
    v_complete:=true;
    v_winner:=case
      when v_score_a>v_score_b then v_match.challenger_id::text
      else v_match.opponent_id::text
    end;
  end if;

  if v_complete then
    v_result:=jsonb_set(v_match.result,'{winner}',to_jsonb(v_winner),true);
    v_result:=jsonb_set(v_result,'{penalties}',jsonb_build_object('a',v_score_a,'b',v_score_b),true);
    v_result:=jsonb_set(
      v_result,
      '{penalty_shootout}',
      (v_match.result->'penalty_shootout')
        ||jsonb_build_object(
          'score',jsonb_build_object('a',v_score_a,'b',v_score_b),
          'kicks',v_kicks,
          'status','completed'
        )-'next',
      true
    );

    update public.fa_x1_matches
    set status='completed',result=v_result,completed_at=now()
    where id=v_match.id
    returning * into v_match;

    delete from private.fa_x1_penalty_choices where match_id=v_match.id;
    return to_jsonb(v_match);
  end if;

  v_next_team:=case when v_team='a' then 'b' else 'a' end;
  v_result:=jsonb_set(v_match.result,'{penalties}',jsonb_build_object('a',v_score_a,'b',v_score_b),true);
  v_result:=jsonb_set(
    v_result,
    '{penalty_shootout}',
    (v_match.result->'penalty_shootout')
      ||jsonb_build_object(
        'score',jsonb_build_object('a',v_score_a,'b',v_score_b),
        'kicks',v_kicks,
        'status','pending',
        'next',jsonb_build_object(
          'index',v_kick_no+1,
          'team',v_next_team,
          'suddenDeath',(v_taken_a>=5 and v_taken_b>=5)
        )
      ),
    true
  );

  update public.fa_x1_matches
  set result=v_result
  where id=v_match.id
  returning * into v_match;

  delete from private.fa_x1_penalty_choices
  where match_id=v_match.id and kick_no=v_kick_no;

  return to_jsonb(v_match);
end;
$function$;

revoke all on function public.fa_get_x1_penalty_setup(uuid) from public,anon;
revoke all on function public.fa_set_x1_penalty_order(uuid,text[]) from public,anon;
revoke all on function public.fa_start_x1_penalties(uuid) from public,anon;
revoke all on function public.fa_choose_x1_penalty(uuid,text) from public,anon;

grant execute on function public.fa_get_x1_penalty_setup(uuid) to authenticated;
grant execute on function public.fa_set_x1_penalty_order(uuid,text[]) to authenticated;
grant execute on function public.fa_start_x1_penalties(uuid) to authenticated;
grant execute on function public.fa_choose_x1_penalty(uuid,text) to authenticated;
