create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  avatar_url text,
  created_at timestamptz default now()
);

create table projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  invite_code text unique not null
    default upper(substr(replace(gen_random_uuid()::text,'-',''),1,6)),
  due_date date,
  status text not null default 'in_progress'
    check (status in ('in_progress','completed','cancelled')),
  created_by uuid references profiles(id) default auth.uid(),
  created_at timestamptz default now()
);

create table project_members (
  project_id uuid references projects(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  role text not null check (role in ('admin','member')),
  joined_at timestamptz default now(),
  primary key (project_id, user_id)
);

create table tasks (  -- tampil di UI sebagai Subtask
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'todo'
    check (status in ('todo','in_progress','completed','cancelled')),
  created_at timestamptz default now(),
  unique (id, project_id)
);

create table task_assignees (
  task_id uuid not null,
  project_id uuid not null,
  user_id uuid not null,
  primary key (task_id, user_id),
  foreign key (task_id, project_id) references tasks(id, project_id) on delete cascade,
  foreign key (project_id, user_id) references project_members(project_id, user_id) on delete cascade
);

create table join_requests (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade default auth.uid(),
  status text not null default 'pending'
    check (status in ('pending','approved','declined')),
  created_at timestamptz default now(),
  unique (project_id, user_id)
);

create table project_invitations (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  invited_email text not null,
  invited_by uuid references profiles(id) default auth.uid(),
  status text not null default 'pending'
    check (status in ('pending','accepted','declined')),
  created_at timestamptz default now()
);

-- Baris profiles otomatis saat daftar (email maupun Google)
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, full_name, email, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name',
             new.raw_user_meta_data->>'name',
             split_part(new.email,'@',1)),
    new.email,
    coalesce(new.raw_user_meta_data->>'avatar_url',
             new.raw_user_meta_data->>'picture')
  );
  return new;
end $$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function handle_new_user();

-- Realtime
alter publication supabase_realtime add table
  tasks, project_members, join_requests, project_invitations;