-- Prasyarat: baseline origin/feature/RLS:supabase/rls.sql sudah diterapkan.
-- Policy "tasks update" memeriksa Admin atau assignee. Trigger tasks_status_guard
-- memanggil fungsi ini sebelum setiap perubahan baris tasks.
begin;

create or replace function tasks_member_only_status() returns trigger
language plpgsql as $$
begin
  if not is_admin(old.project_id) then
    if (to_jsonb(new) - 'status')
       is distinct from (to_jsonb(old) - 'status') then
      raise exception 'HANYA_ADMIN';
    end if;
  end if;
  return new;
end $$;

commit;
