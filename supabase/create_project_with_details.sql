begin;

create or replace function public.create_project_with_details(
  p_name text,
  p_description text,
  p_due_date date,
  p_member_ids uuid[],
  p_subtasks text[]
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_creator_id uuid := auth.uid();
  v_project_id uuid := gen_random_uuid();
  v_constraint text;
begin
  if v_creator_id is null then
    raise exception 'Silakan login terlebih dahulu.' using errcode = '42501';
  end if;
  if p_name is null or p_name !~ '[^[:space:]]' then
    raise exception 'Nama proyek wajib diisi.' using errcode = '22023';
  end if;

  -- Satu percobaan awal dan maksimal lima pengulangan untuk benturan invite_code.
  for attempt in 0..5 loop
    begin
      insert into public.projects (id, name, description, due_date, created_by)
      values (v_project_id, p_name, p_description, p_due_date, v_creator_id);
      exit;
    exception when unique_violation then
      get stacked diagnostics v_constraint = constraint_name;
      if v_constraint <> 'projects_invite_code_key' or attempt = 5 then
        raise;
      end if;
    end;
  end loop;

  insert into public.project_members (project_id, user_id, role)
  values (v_project_id, v_creator_id, 'admin');

  insert into public.project_members (project_id, user_id, role)
  select distinct v_project_id, member_id, 'member'
  from unnest(p_member_ids) as members(member_id)
  where member_id <> v_creator_id;

  insert into public.tasks (project_id, title)
  select v_project_id, title
  from unnest(p_subtasks) as subtasks(title)
  where title ~ '[^[:space:]]';

  return v_project_id;
end;
$$;

revoke all on function public.create_project_with_details(text, text, date, uuid[], text[])
  from public, anon, service_role;
grant execute on function public.create_project_with_details(text, text, date, uuid[], text[])
  to authenticated;

commit;
