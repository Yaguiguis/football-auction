create or replace function private.fa_cancel_pending_trades_when_finalized()
returns trigger
language plpgsql
security definer
set search_path=''
as $function$
begin
  if new.squad_finalized and not old.squad_finalized then
    update public.fa_trade_requests
    set status='cancelled',responded_at=now()
    where status='pending'
      and (requester_member_id=new.id or recipient_member_id=new.id);
  end if;
  return new;
end;
$function$;

drop trigger if exists fa_cancel_pending_trades_when_finalized
on public.fa_room_members;

create trigger fa_cancel_pending_trades_when_finalized
after update of squad_finalized on public.fa_room_members
for each row
when (new.squad_finalized is distinct from old.squad_finalized)
execute function private.fa_cancel_pending_trades_when_finalized();
