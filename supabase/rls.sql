-- Helper (security definer supaya tidak rekursi policy)
create or replace function is_member(pid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from project_members
                 where project_id = pid and user_id = auth.uid());
$$;

create or replace function is_admin(pid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from project_members
                 where project_id = pid and user_id = auth.uid() and role = 'admin');
$$;

-- profiles
alter table profiles enable row level security;
create policy "profiles read"   on profiles for select to authenticated using (true);
create policy "profiles update" on profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- projects
alter table projects enable row level security;
create policy "projects read"   on projects for select to authenticated
  using (is_member(id) or created_by = auth.uid());
create policy "projects insert" on projects for insert to authenticated
  with check (created_by = auth.uid());
create policy "projects update" on projects for update to authenticated
  using (is_admin(id));
create policy "projects delete" on projects for delete to authenticated
  using (is_admin(id));