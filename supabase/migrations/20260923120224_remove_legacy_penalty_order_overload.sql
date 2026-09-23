drop function if exists public.fa_set_x1_penalty_order(uuid,uuid[]);

revoke all on function public.fa_set_x1_penalty_order(uuid,text[]) from public,anon;
grant execute on function public.fa_set_x1_penalty_order(uuid,text[]) to authenticated;
