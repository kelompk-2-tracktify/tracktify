-- Dokumentasi fitur Orang 3. File ini tidak perlu dijalankan karena
-- seluruh struktur yang digunakan sudah didefinisikan di supabase/schema.sql.

-- projects menyimpan nama, deskripsi, kode undangan, tenggat, dan status proyek.
-- created_by mengacu ke profiles.id, yang juga mengacu ke auth.users.id.
-- Status awal proyek adalah 'in_progress'.

-- project_members menghubungkan project_id ke projects.id dan user_id ke
-- profiles.id. Kunci utama (project_id, user_id) memberi setiap anggota satu
-- role per proyek, yaitu 'admin' atau 'member'.

-- tasks menyimpan subtask dengan judul, deskripsi, dan status awal 'todo'.
-- tasks.project_id mengacu ke projects.id. Aplikasi menghitung progress
-- dengan membagi jumlah subtask berstatus 'completed' dengan jumlah seluruh
-- subtask proyek, termasuk yang 'cancelled'. Jika kosong, progress bernilai 0.

-- task_assignees mencatat penugasan dengan kunci utama (task_id, user_id).
-- FK (task_id, project_id) mengacu ke tasks(id, project_id) dan
-- FK (project_id, user_id) mengacu ke project_members(project_id, user_id).
-- Kedua FK memastikan penerima tugas adalah anggota proyek subtask tersebut.

-- RPC public.create_project_with_details didefinisikan di
-- supabase/create_project_with_details.sql. Dalam satu transaksi, RPC membuat
-- proyek, mendaftarkan creator sebagai 'admin', menambahkan anggota pilihan
-- sebagai 'member', lalu menyimpan subtask dan mengembalikan UUID proyek.
-- Penugasan subtask melalui task_assignees dilakukan terpisah dari RPC ini.
