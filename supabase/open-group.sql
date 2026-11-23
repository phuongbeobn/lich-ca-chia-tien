-- Switch an existing invite-only setup to an open shared group.
-- Any authenticated account can now join automatically and access shared expenses.

drop function if exists public.join_shared_group(text);
alter table public.shared_groups drop column if exists invite_code_hash;
alter table public.shared_expenses add column if not exists participants text[] not null default array['phuong', 'dung', 'duong']::text[];
alter table public.shared_expenses drop constraint if exists shared_expenses_participants_check;
alter table public.shared_expenses add constraint shared_expenses_participants_check
  check (cardinality(participants) between 1 and 3 and participants <@ array['phuong', 'dung', 'duong']::text[]);

create or replace function public.my_shared_groups()
returns table (group_id uuid, group_name text)
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Bạn cần đăng nhập trước.';
  end if;

  insert into public.shared_group_members (group_id, user_id)
  select group_row.id, (select auth.uid())
  from public.shared_groups as group_row
  on conflict do nothing;

  return query
  select group_row.id, group_row.name
  from public.shared_groups as group_row
  order by group_row.created_at;
end;
$$;

revoke all on function public.my_shared_groups() from public, anon;
grant execute on function public.my_shared_groups() to authenticated;

drop policy if exists "Group members remove shared expenses" on public.shared_expenses;
drop policy if exists "Authors remove own shared expenses" on public.shared_expenses;
create policy "Authors remove own shared expenses"
  on public.shared_expenses for delete to authenticated
  using (
    private.is_shared_group_member(group_id)
    and created_by = (select auth.uid())
  );
