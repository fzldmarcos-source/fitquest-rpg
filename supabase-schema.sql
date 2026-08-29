create table if not exists public.fitquest_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.fitquest_progress enable row level security;

drop policy if exists "fitquest_select_own" on public.fitquest_progress;
create policy "fitquest_select_own" on public.fitquest_progress
for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "fitquest_insert_own" on public.fitquest_progress;
create policy "fitquest_insert_own" on public.fitquest_progress
for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "fitquest_update_own" on public.fitquest_progress;
create policy "fitquest_update_own" on public.fitquest_progress
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.fitquest_progress from anon;
grant usage on schema public to authenticated;
grant select, insert, update on table public.fitquest_progress to authenticated;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'fitquest_progress'
  ) then
    alter publication supabase_realtime add table public.fitquest_progress;
  end if;
end $$;
