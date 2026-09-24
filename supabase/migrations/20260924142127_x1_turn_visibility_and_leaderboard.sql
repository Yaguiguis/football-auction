
create table if not exists public.fa_x1_records (
  room_id uuid not null references public.fa_rooms(id) on delete cascade,
  member_id uuid not null references public.fa_room_members(id) on delete cascade,
  played integer not null default 0 check (played>=0),
  wins integer not null default 0 check (wins>=0),
  losses integer not null default 0 check (losses>=0),
  goals_for integer not null default 0 check (goals_for>=0),
  goals_against integer not null default 0 check (goals_against>=0),
  penalty_wins integer not null default 0 check (penalty_wins>=0),
  updated_at timestamptz not null default now(),
  primary key(room_id,member_id)
);

create index if not exists fa_x1_records_room_rank_idx
  on public.fa_x1_records(room_id,wins desc,played asc);

alter table public.fa_x1_records enable row level security;

drop policy if exists fa_x1_records_room_select on public.fa_x1_records;
create policy fa_x1_records_room_select
on public.fa_x1_records
for select
to authenticated
using (
  exists(
    select 1
    from public.fa_room_members me
    where me.room_id=fa_x1_records.room_id
      and me.user_id=(select auth.uid())
      and me.kicked_at is null
  )
);

revoke all on public.fa_x1_records from public,anon;
grant select on public.fa_x1_records to authenticated;

create or replace function private.fa_record_x1_result(
  p_room_id uuid,
  p_challenger_id uuid,
  p_opponent_id uuid,
  p_result jsonb
)
returns void
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_winner uuid;
  v_score_a integer;
  v_score_b integer;
  v_penalty boolean;
begin
  if p_result is null or p_result->>'winner' is null then
    return;
  end if;

  v_winner:=(p_result->>'winner')::uuid;
  v_score_a:=coalesce((p_result#>>'{score,a}')::integer,0);
  v_score_b:=coalesce((p_result#>>'{score,b}')::integer,0);
  v_penalty:=coalesce(p_result->>'decided_by','')='penalties';

  if v_winner not in (p_challenger_id,p_opponent_id) then
    return;
  end if;

  insert into public.fa_x1_records(
    room_id,member_id,played,wins,losses,goals_for,goals_against,penalty_wins,updated_at
  )
  values(
    p_room_id,
    p_challenger_id,
    1,
    case when v_winner=p_challenger_id then 1 else 0 end,
    case when v_winner=p_challenger_id then 0 else 1 end,
    v_score_a,
    v_score_b,
    case when v_winner=p_challenger_id and v_penalty then 1 else 0 end,
    now()
  )
  on conflict(room_id,member_id) do update set
    played=public.fa_x1_records.played+1,
    wins=public.fa_x1_records.wins+excluded.wins,
    losses=public.fa_x1_records.losses+excluded.losses,
    goals_for=public.fa_x1_records.goals_for+excluded.goals_for,
    goals_against=public.fa_x1_records.goals_against+excluded.goals_against,
    penalty_wins=public.fa_x1_records.penalty_wins+excluded.penalty_wins,
    updated_at=now();

  insert into public.fa_x1_records(
    room_id,member_id,played,wins,losses,goals_for,goals_against,penalty_wins,updated_at
  )
  values(
    p_room_id,
    p_opponent_id,
    1,
    case when v_winner=p_opponent_id then 1 else 0 end,
    case when v_winner=p_opponent_id then 0 else 1 end,
    v_score_b,
    v_score_a,
    case when v_winner=p_opponent_id and v_penalty then 1 else 0 end,
    now()
  )
  on conflict(room_id,member_id) do update set
    played=public.fa_x1_records.played+1,
    wins=public.fa_x1_records.wins+excluded.wins,
    losses=public.fa_x1_records.losses+excluded.losses,
    goals_for=public.fa_x1_records.goals_for+excluded.goals_for,
    goals_against=public.fa_x1_records.goals_against+excluded.goals_against,
    penalty_wins=public.fa_x1_records.penalty_wins+excluded.penalty_wins,
    updated_at=now();
end;
$function$;

create or replace function private.fa_x1_records_trigger()
returns trigger
language plpgsql
security definer
set search_path=''
as $function$
begin
  if tg_op='INSERT' then
    if new.status='completed' and new.result is not null then
      perform private.fa_record_x1_result(
        new.room_id,new.challenger_id,new.opponent_id,new.result
      );
    end if;
  elsif new.status='completed'
        and old.status is distinct from 'completed'
        and new.result is not null then
    perform private.fa_record_x1_result(
      new.room_id,new.challenger_id,new.opponent_id,new.result
    );
  end if;

  return new;
end;
$function$;

drop trigger if exists fa_x1_records_after_complete on public.fa_x1_matches;
create trigger fa_x1_records_after_complete
after insert or update of status on public.fa_x1_matches
for each row
execute function private.fa_x1_records_trigger();

with totals as (
  select
    x.room_id,
    m.member_id,
    count(*)::integer as played,
    count(*) filter (where (x.result->>'winner')::uuid=m.member_id)::integer as wins,
    count(*) filter (where (x.result->>'winner')::uuid<>m.member_id)::integer as losses,
    sum(
      case when m.side='a'
        then coalesce((x.result#>>'{score,a}')::integer,0)
        else coalesce((x.result#>>'{score,b}')::integer,0)
      end
    )::integer as goals_for,
    sum(
      case when m.side='a'
        then coalesce((x.result#>>'{score,b}')::integer,0)
        else coalesce((x.result#>>'{score,a}')::integer,0)
      end
    )::integer as goals_against,
    count(*) filter (
      where (x.result->>'winner')::uuid=m.member_id
        and x.result->>'decided_by'='penalties'
    )::integer as penalty_wins
  from public.fa_x1_matches x
  cross join lateral (
    values
      (x.challenger_id,'a'::text),
      (x.opponent_id,'b'::text)
  ) m(member_id,side)
  where x.status='completed'
    and x.result is not null
    and x.result->>'winner' is not null
  group by x.room_id,m.member_id
)
insert into public.fa_x1_records(
  room_id,member_id,played,wins,losses,goals_for,goals_against,penalty_wins,updated_at
)
select
  room_id,member_id,played,wins,losses,goals_for,goals_against,penalty_wins,now()
from totals
on conflict(room_id,member_id) do update set
  played=excluded.played,
  wins=excluded.wins,
  losses=excluded.losses,
  goals_for=excluded.goals_for,
  goals_against=excluded.goals_against,
  penalty_wins=excluded.penalty_wins,
  updated_at=now();

create or replace function public.fa_x1_leaderboard(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user uuid:=auth.uid();
begin
  if v_user is null then
    raise exception 'authentication required';
  end if;

  if not exists(
    select 1
    from public.fa_room_members me
    where me.room_id=p_room_id
      and me.user_id=v_user
      and me.kicked_at is null
  ) then
    raise exception 'not a room member';
  end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'member_id',ranked.member_id,
        'name',ranked.display_name,
        'played',ranked.played,
        'wins',ranked.wins,
        'losses',ranked.losses,
        'goals_for',ranked.goals_for,
        'goals_against',ranked.goals_against,
        'goal_difference',ranked.goal_difference,
        'penalty_wins',ranked.penalty_wins,
        'win_rate',ranked.win_rate,
        'rank',ranked.rank_no
      )
      order by ranked.rank_no,ranked.display_name
    )
    from (
      select
        m.id as member_id,
        m.display_name,
        coalesce(r.played,0) as played,
        coalesce(r.wins,0) as wins,
        coalesce(r.losses,0) as losses,
        coalesce(r.goals_for,0) as goals_for,
        coalesce(r.goals_against,0) as goals_against,
        coalesce(r.goals_for,0)-coalesce(r.goals_against,0) as goal_difference,
        coalesce(r.penalty_wins,0) as penalty_wins,
        case
          when coalesce(r.played,0)=0 then 0
          else round((100.0*coalesce(r.wins,0)/r.played)::numeric,1)
        end as win_rate,
        row_number() over(
          order by
            coalesce(r.wins,0) desc,
            case
              when coalesce(r.played,0)=0 then 0
              else r.wins::numeric/r.played
            end desc,
            (coalesce(r.goals_for,0)-coalesce(r.goals_against,0)) desc,
            m.joined_at asc
        ) as rank_no
      from public.fa_room_members m
      left join public.fa_x1_records r
        on r.room_id=m.room_id
       and r.member_id=m.id
      where m.room_id=p_room_id
        and m.kicked_at is null
        and not m.is_spectator
    ) ranked
  ),'[]'::jsonb);
end;
$function$;

create or replace function public.fa_get_x1_penalty_turn_state(p_match_id uuid)
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
  v_shooter uuid;
  v_keeper uuid;
  v_role text:='spectator';
  v_my_chosen boolean:=false;
  v_other_chosen boolean:=false;
begin
  if v_user is null then
    raise exception 'authentication required';
  end if;

  select * into v_match
  from public.fa_x1_matches
  where id=p_match_id;

  if not found then
    raise exception 'match not found';
  end if;

  select * into v_me
  from public.fa_room_members
  where room_id=v_match.room_id
    and user_id=v_user
    and kicked_at is null;

  if not found then
    raise exception 'not a room member';
  end if;

  if v_match.status<>'shootout' then
    return jsonb_build_object(
      'active',false,
      'role','none',
      'my_chosen',false,
      'other_chosen',false
    );
  end if;

  v_next:=v_match.result#>'{penalty_shootout,next}';

  if v_next is null then
    return jsonb_build_object(
      'active',false,
      'role',case when v_me.is_spectator then 'spectator' else 'none' end,
      'my_chosen',false,
      'other_chosen',false
    );
  end if;

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
  end if;

  if v_role in ('shot','keeper') then
    select exists(
      select 1
      from private.fa_x1_penalty_choices c
      where c.match_id=v_match.id
        and c.kick_no=v_kick_no
        and c.role=v_role
        and c.member_id=v_me.id
    )
    into v_my_chosen;

    select exists(
      select 1
      from private.fa_x1_penalty_choices c
      where c.match_id=v_match.id
        and c.kick_no=v_kick_no
        and c.role=case when v_role='shot' then 'keeper' else 'shot' end
    )
    into v_other_chosen;
  end if;

  return jsonb_build_object(
    'active',true,
    'kick_no',v_kick_no,
    'team',v_team,
    'role',v_role,
    'my_chosen',v_my_chosen,
    'other_chosen',v_other_chosen,
    'shooter_id',v_shooter,
    'keeper_id',v_keeper,
    'sudden_death',coalesce((v_next->>'suddenDeath')::boolean,false)
  );
end;
$function$;

revoke all on function public.fa_x1_leaderboard(uuid) from public,anon;
revoke all on function public.fa_get_x1_penalty_turn_state(uuid) from public,anon;
grant execute on function public.fa_x1_leaderboard(uuid) to authenticated;
grant execute on function public.fa_get_x1_penalty_turn_state(uuid) to authenticated;
