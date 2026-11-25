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

-- project_members
alter table project_members enable row level security;
create policy "members read" on project_members for select to authenticated
  using (is_member(project_id));
-- admin boleh menambah anggota; pembuat project boleh menjadikan dirinya admin pertama
create policy "members insert" on project_members for insert to authenticated
  with check (
    is_admin(project_id)
    or (user_id = auth.uid() and role = 'admin'
        and exists (select 1 from projects p
                    where p.id = project_id and p.created_by = auth.uid()))
  );
create policy "members update" on project_members for update to authenticated
  using (is_admin(project_id));
-- admin mengeluarkan anggota, atau anggota keluar sendiri (Leave Project)
create policy "members delete" on project_members for delete to authenticated
  using (is_admin(project_id) or user_id = auth.uid());

-- tasks
alter table tasks enable row level security;
create policy "tasks read"   on tasks for select to authenticated using (is_member(project_id));
create policy "tasks insert" on tasks for insert to authenticated with check (is_admin(project_id));
create policy "tasks delete" on tasks for delete to authenticated using (is_admin(project_id));
create policy "tasks update" on tasks for update to authenticated
  using (
    is_admin(project_id)
    or exists (select 1 from task_assignees ta
               where ta.task_id = tasks.id and ta.user_id = auth.uid())
  );

-- anggota biasa hanya boleh mengubah kolom status
create or replace function tasks_member_only_status() returns trigger
language plpgsql as $$
begin
  if not is_admin(old.project_id) then
    if new.title is distinct from old.title
       or new.description is distinct from old.description
       or new.project_id is distinct from old.project_id then
      raise exception 'HANYA_ADMIN';
    end if;
  end if;
  return new;
end $$;

create trigger tasks_status_guard before update on tasks
for each row execute function tasks_member_only_status();

-- task_assignees
alter table task_assignees enable row level security;
create policy "assignees read"   on task_assignees for select to authenticated using (is_member(project_id));
create policy "assignees insert" on task_assignees for insert to authenticated with check (is_admin(project_id));
create policy "assignees delete" on task_assignees for delete to authenticated using (is_admin(project_id));

-- join_requests: membuat request HANYA lewat fungsi send_join_request
alter table join_requests enable row level security;
create policy "requests read" on join_requests for select to authenticated
  using (user_id = auth.uid() or is_admin(project_id));
create policy "requests admin update" on join_requests for update to authenticated
  using (is_admin(project_id));
create policy "requests cancel" on join_requests for delete to authenticated
  using (user_id = auth.uid() and status = 'pending');

-- project_invitations
alter table project_invitations enable row level security;
create policy "invites read" on project_invitations for select to authenticated
  using (is_admin(project_id)
         or lower(invited_email) = lower(auth.jwt() ->> 'email'));
create policy "invites insert" on project_invitations for insert to authenticated
  with check (is_admin(project_id));
create policy "invites delete" on project_invitations for delete to authenticated
  using (is_admin(project_id));

create or replace function send_join_request(code text) returns void
language plpgsql security definer set search_path = public as $$
declare pid uuid;
begin
  select id into pid from projects where invite_code = upper(trim(code));
  if pid is null then raise exception 'KODE_SALAH'; end if;
  if is_member(pid) then raise exception 'SUDAH_ANGGOTA'; end if;
  if exists (select 1 from join_requests
             where project_id = pid and user_id = auth.uid() and status = 'pending')
    then raise exception 'REQUEST_ADA'; end if;
  insert into join_requests (project_id, user_id) values (pid, auth.uid())
  on conflict (project_id, user_id)
  do update set status = 'pending', created_at = now();
end $$;

-- daftar request pending milik sendiri, lengkap dengan nama project
create or replace function my_join_requests()
returns table (id uuid, project_id uuid, project_name text, status text, created_at timestamptz)
language sql stable security definer set search_path = public as $$
  select r.id, r.project_id, p.name, r.status, r.created_at
  from join_requests r join projects p on p.id = r.project_id
  where r.user_id = auth.uid() and r.status = 'pending';
$$;

-- untuk Direct Invitations
create or replace function my_invitations()
returns table (id uuid, project_id uuid, project_name text, invited_by_name text)
language sql stable security definer set search_path = public as $$
  select i.id, i.project_id, p.name, pr.full_name
  from project_invitations i
  join projects p on p.id = i.project_id
  left join profiles pr on pr.id = i.invited_by
  where i.status = 'pending'
    and lower(i.invited_email) = lower(auth.jwt() ->> 'email');
$$;

create or replace function accept_invitation(inv uuid) returns void
language plpgsql security definer set search_path = public as $$
declare r project_invitations;
begin
  select * into r from project_invitations
  where id = inv and status = 'pending'
    and lower(invited_email) = lower(auth.jwt() ->> 'email');
  if r.id is null then raise exception 'UNDANGAN_TIDAK_VALID'; end if;
  insert into project_members (project_id, user_id, role)
  values (r.project_id, auth.uid(), 'member') on conflict do nothing;
  update project_invitations set status = 'accepted' where id = inv;
end $$;

create or replace function decline_invitation(inv uuid) returns void
language sql security definer set search_path = public as $$
  update project_invitations set status = 'declined'
  where id = inv and status = 'pending'
    and lower(invited_email) = lower(auth.jwt() ->> 'email');
$$;