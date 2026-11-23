-- Publicly joinable shared expenses with email/password sign-in,
-- Row Level Security, and realtime updates. Any authenticated account joins
-- the shared group automatically and can read, add, and delete its expenses.

create extension if not exists pgcrypto with schema extensions;
create schema if not exists private;

create table if not exists public.shared_groups (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Nhóm chi tiêu',
  created_at timestamptz not null default now()
);

create table if not exists public.shared_group_members (
  group_id uuid not null references public.shared_groups(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

create table if not exists public.shared_expenses (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.shared_groups(id) on delete cascade,
  paid_by text not null check (paid_by in ('phuong', 'dung', 'duong')),
  participants text[] not null default array['phuong', 'dung', 'duong']::text[] check (cardinality(participants) between 1 and 3 and participants <@ array['phuong', 'dung', 'duong']::text[]),
  amount bigint not null check (amount > 0),
  note text not null default '',
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

alter table public.shared_groups enable row level security;
alter table public.shared_group_members enable row level security;
alter table public.shared_expenses enable row level security;

revoke all on table public.shared_groups from anon, authenticated;
revoke all on table public.shared_group_members from anon, authenticated;
revoke all on table public.shared_expenses from anon, authenticated;
grant select, insert, delete on table public.shared_expenses to authenticated;

create or replace function private.is_shared_group_member(target_group uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.shared_group_members as member
    where member.group_id = target_group
      and member.user_id = (select auth.uid())
  );
$$;

revoke all on function private.is_shared_group_member(uuid) from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.is_shared_group_member(uuid) to authenticated;

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

drop policy if exists "Group members read shared expenses" on public.shared_expenses;
create policy "Group members read shared expenses"
  on public.shared_expenses for select to authenticated
  using (private.is_shared_group_member(group_id));

drop policy if exists "Group members add shared expenses" on public.shared_expenses;
create policy "Group members add shared expenses"
  on public.shared_expenses for insert to authenticated
  with check (
    private.is_shared_group_member(group_id)
    and created_by = (select auth.uid())
  );

drop policy if exists "Group members remove shared expenses" on public.shared_expenses;
create policy "Authors remove own shared expenses"
  on public.shared_expenses for delete to authenticated
  using (
    private.is_shared_group_member(group_id)
    and created_by = (select auth.uid())
  );

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'shared_expenses'
  ) then
    alter publication supabase_realtime add table public.shared_expenses;
  end if;
end;
$$;
