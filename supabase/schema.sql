create extension if not exists pgcrypto;

create table if not exists rooms (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  mode text not null check (mode in ('football','futsal')),
  budget integer not null default 100,
  status text not null default 'lobby',
  created_at timestamptz not null default now()
);

create table if not exists room_members (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references rooms(id) on delete cascade,
  display_name text not null,
  balance integer not null,
  joined_at timestamptz not null default now()
);

create table if not exists players (
  id text primary key,
  name text not null,
  club text,
  league text,
  nationality text,
  primary_position text not null,
  secondary_positions text[] not null default '{}',
  overall integer,
  player_type text not null default 'ACTIVE',
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists auctions (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references rooms(id) on delete cascade,
  player_id text not null references players(id),
  current_bid integer not null default 0,
  current_bidder_id uuid references room_members(id),
  status text not null default 'interest',
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists bids (
  id uuid primary key default gen_random_uuid(),
  auction_id uuid not null references auctions(id) on delete cascade,
  bidder_id uuid not null references room_members(id) on delete cascade,
  amount integer not null,
  created_at timestamptz not null default now()
);

create table if not exists squad_players (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references room_members(id) on delete cascade,
  player_id text not null references players(id),
  slot_key text not null,
  is_bench boolean not null default false,
  unique(member_id, player_id)
);
