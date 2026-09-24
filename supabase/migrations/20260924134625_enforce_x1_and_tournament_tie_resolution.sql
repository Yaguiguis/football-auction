
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
  v_score_a integer;
  v_score_b integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_match
  from public.fa_x1_matches
  where id=p_match_id
  for update;

  if not found then raise exception 'match not found'; end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_match.room_id
    and user_id=v_user
    and kicked_at is null;

  if not found or v_me.id<>v_match.opponent_id then
    raise exception 'only challenged player can respond';
  end if;

  if v_match.status<>'pending' then
    return to_jsonb(v_match);
  end if;

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

  v_score_a:=coalesce((v_result#>>'{score,a}')::integer,0);
  v_score_b:=coalesce((v_result#>>'{score,b}')::integer,0);

  -- A tied knockout match can never be completed before the interactive shootout.
  if v_score_a=v_score_b then
    v_status:='shootout';
    v_result:=jsonb_set(v_result,'{winner}','null'::jsonb,true);
    v_result:=jsonb_set(v_result,'{decided_by}',to_jsonb('penalties'::text),true);
    v_result:=jsonb_set(
      v_result,
      '{penalties}',
      jsonb_build_object('a',0,'b',0),
      true
    );

    v_shootout:=coalesce(v_result->'penalty_shootout','{}'::jsonb);
    v_shootout:=(v_shootout-'next')
      ||jsonb_build_object(
        'score',jsonb_build_object('a',0,'b',0),
        'kicks','[]'::jsonb,
        'status','setup',
        'setup',jsonb_build_object('status','selecting')
      );

    v_result:=jsonb_set(v_result,'{penalty_shootout}',v_shootout,true);
  else
    v_status:='completed';

    if v_result->>'winner' is null then
      v_result:=jsonb_set(
        v_result,
        '{winner}',
        to_jsonb(
          case
            when v_score_a>v_score_b then v_match.challenger_id::text
            else v_match.opponent_id::text
          end
        ),
        true
      );
    end if;
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

create or replace function public.fa_play_tournament_round(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_round integer;
  v_match public.fa_tournament_matches%rowtype;
  v_a jsonb;
  v_b jsonb;
  v_seed bigint;
  v_result jsonb;
  v_winner uuid;
  v_winners uuid[];
  v_count integer;
  v_i integer;
  v_next_round integer;
  v_created integer:=0;
  v_played integer:=0;
  v_score_a integer;
  v_score_b integer;
  v_pen_a integer;
  v_pen_b integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.room_kind<>'tournament' then raise exception 'not a tournament room'; end if;
  if v_room.host_user_id<>v_user then raise exception 'host only'; end if;
  if v_room.status not in ('squads','finished') then
    raise exception 'tournament is not ready';
  end if;

  if not exists(
    select 1 from public.fa_tournament_matches where room_id=p_room_id
  ) then
    perform private.fa_tournament_initialize(p_room_id);
  end if;

  if v_room.tournament_champion_member_id is not null then
    return jsonb_build_object(
      'finished',true,
      'champion_member_id',v_room.tournament_champion_member_id
    );
  end if;

  select min(round_no) into v_round
  from public.fa_tournament_matches
  where room_id=p_room_id and status='pending';

  if v_round is null then
    select max(round_no) into v_round
    from public.fa_tournament_matches
    where room_id=p_room_id;
  end if;

  for v_match in
    select *
    from public.fa_tournament_matches
    where room_id=p_room_id
      and round_no=v_round
      and status='pending'
    order by match_no
    for update
  loop
    if v_match.member_a_id is null or v_match.member_b_id is null then
      raise exception 'invalid tournament pairing';
    end if;

    v_a:=private.fa_x1_snapshot(v_match.member_a_id);
    v_b:=private.fa_x1_snapshot(v_match.member_b_id);
    v_seed:=(('x'||encode(extensions.gen_random_bytes(4),'hex'))::bit(32)::bigint % 2147483646)+1;
    v_result:=private.fa_simulate_knockout_match_v2(v_a,v_b,v_seed,true);

    v_score_a:=coalesce((v_result#>>'{score,a}')::integer,0);
    v_score_b:=coalesce((v_result#>>'{score,b}')::integer,0);

    if v_score_a=v_score_b then
      v_pen_a:=coalesce((v_result#>>'{penalties,a}')::integer,0);
      v_pen_b:=coalesce((v_result#>>'{penalties,b}')::integer,0);

      if v_result->>'decided_by'<>'penalties'
         or v_pen_a=v_pen_b
         or v_result->>'winner' is null
      then
        raise exception 'tied tournament match was not resolved by penalties';
      end if;
    elsif v_result->>'winner' is null then
      raise exception 'non-tied tournament match has no winner';
    end if;

    v_winner:=(v_result->>'winner')::uuid;

    if v_winner not in (v_match.member_a_id,v_match.member_b_id) then
      raise exception 'tournament simulation returned invalid winner';
    end if;

    update public.fa_tournament_matches
    set status='completed',
        winner_member_id=v_winner,
        seed=v_seed,
        team_a=v_a,
        team_b=v_b,
        result=v_result,
        played_at=now()
    where id=v_match.id;

    v_played:=v_played+1;
  end loop;

  if exists(
    select 1
    from public.fa_tournament_matches
    where room_id=p_room_id
      and round_no=v_round
      and status='pending'
  ) then
    return jsonb_build_object(
      'finished',false,
      'round',v_round,
      'played',v_played
    );
  end if;

  select array_agg(winner_member_id order by match_no)
  into v_winners
  from public.fa_tournament_matches
  where room_id=p_room_id
    and round_no=v_round
    and winner_member_id is not null;

  v_count:=coalesce(cardinality(v_winners),0);

  if v_count=1 then
    update public.fa_rooms
    set tournament_champion_member_id=v_winners[1],
        status='finished'
    where id=p_room_id;

    return jsonb_build_object(
      'finished',true,
      'round',v_round,
      'played',v_played,
      'champion_member_id',v_winners[1]
    );
  end if;

  if v_count<2 or mod(v_count,2)<>0 then
    raise exception 'invalid tournament winners count';
  end if;

  v_next_round:=v_round+1;

  if not exists(
    select 1
    from public.fa_tournament_matches
    where room_id=p_room_id
      and round_no=v_next_round
  ) then
    v_i:=1;

    while v_i<=v_count loop
      insert into public.fa_tournament_matches(
        room_id,round_no,match_no,member_a_id,member_b_id,status
      )
      values(
        p_room_id,
        v_next_round,
        ((v_i+1)/2),
        v_winners[v_i],
        v_winners[v_i+1],
        'pending'
      );

      v_created:=v_created+1;
      v_i:=v_i+2;
    end loop;
  end if;

  return jsonb_build_object(
    'finished',false,
    'round',v_round,
    'played',v_played,
    'next_round',v_next_round,
    'next_matches',v_created
  );
end;
$function$;

revoke all on function public.fa_respond_x1(uuid,boolean) from public,anon;
revoke all on function public.fa_play_tournament_round(uuid) from public,anon;
grant execute on function public.fa_respond_x1(uuid,boolean) to authenticated;
grant execute on function public.fa_play_tournament_round(uuid) to authenticated;
