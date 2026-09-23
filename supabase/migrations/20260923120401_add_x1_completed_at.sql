alter table public.fa_x1_matches
add column if not exists completed_at timestamptz null;
