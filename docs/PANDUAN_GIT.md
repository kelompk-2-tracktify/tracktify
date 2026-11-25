# Panduan Git dan GitHub Tim Tracktify

Panduan singkat untuk kerja bareng di repo `tracktify`. Simpan di folder `docs/` atau kirim ke grup.

## 1. Gambaran besar

- `main`: versi stabil, hanya diisi di akhir (hari 10)
- `develop`: tempat semua fitur digabung
- `feature/nama-fitur`: branch kerja masing-masing, dibuat dari `develop`

Aturan emas: **jangan pernah push langsung ke `main` atau `develop`**. Semua perubahan masuk lewat Pull Request (PR).

## 2. Setup sekali di awal

1. Pasang Git, Flutter, dan Android Studio, lalu cek dengan `git --version` dan `flutter doctor`
2. Terima undangan kolaborator dari GitHub (cek email atau notifikasi)
3. Atur identitas Git (cukup sekali per laptop):
```bash
git config --global user.name "Nama Kamu"
git config --global user.email "email-github-kamu@gmail.com"
```
4. Clone repo:
```bash
git clone https://github.com/NAMA-ORG/tracktify.git
cd tracktify
git checkout develop
flutter pub get
flutter run
```
Kalau diminta login saat clone atau push, ikuti jendela browser GitHub yang muncul.

## 3. Alur kerja untuk satu fitur

Ulangi alur ini untuk setiap fitur kecil.

**Langkah 1: ambil `develop` terbaru**
```bash
git checkout develop
git pull origin develop
flutter pub get
```

**Langkah 2: buat branch fitur**
```bash
git checkout -b feature/nama-fitur
```
Contoh: `feature/task-list`, `feature/manage-task`, `feature/auth-ui`.

**Langkah 3: kerjakan filenya** di folder fitur milikmu (lihat bagian 6).

**Langkah 4: cek apa yang berubah**
```bash
git status
```

**Langkah 5: simpan perubahan (commit)**
```bash
git add .
git commit -m "feat: tambah task list dengan filter status"
```

**Langkah 6: kirim ke GitHub**
```bash
git push -u origin feature/nama-fitur
```
Untuk push berikutnya di branch yang sama cukup `git push`.

**Langkah 7: buat Pull Request**
1. Buka repo di GitHub, klik **Compare & pull request**
2. Pastikan tujuannya **develop**, bukan main
3. Tulis judul singkat dan apa yang dikerjakan
4. Pilih satu teman di kolom **Reviewers**
5. Klik **Create pull request**

**Langkah 8: merge**
Setelah teman mengecek, klik **Merge pull request**, lalu **Confirm merge**, lalu **Delete branch**. Setelah itu semua orang menjalankan `git pull origin develop`.

## 4. Pesan commit

Awali dengan jenis perubahan:
- `feat:` fitur baru, contoh `feat: tambah halaman join task`
- `fix:` perbaikan bug, contoh `fix: progress ring tidak update`
- `docs:` dokumen, contoh `docs: update README`
- `chore:` hal teknis, contoh `chore: tambah paket supabase_flutter`

Commit sering dengan pesan yang jelas, lebih baik banyak commit kecil daripada satu commit besar.

## 5. Daftar perintah yang sering dipakai

| Perintah | Fungsi |
|---|---|
| `git status` | Lihat file apa yang berubah |
| `git branch` | Lihat daftar branch dan branch aktif |
| `git checkout nama-branch` | Pindah branch |
| `git checkout -b feature/x` | Buat dan pindah ke branch baru |
| `git pull origin develop` | Ambil perubahan terbaru dari develop |
| `git add .` | Siapkan semua perubahan untuk commit |
| `git commit -m "pesan"` | Simpan perubahan |
| `git push` | Kirim commit ke GitHub |
| `git log --oneline` | Lihat riwayat commit singkat |
| `git stash` | Simpan sementara perubahan yang belum di-commit |
| `git stash pop` | Kembalikan perubahan hasil stash |

## 6. Pembagian folder

Setiap orang hanya mengubah folder fitur miliknya, supaya jarang bentrok.

- Orang 1: `lib/features/auth/`, `lib/core/`, `lib/app/`, `supabase/`
- Orang 2: `lib/features/home/`, `lib/features/join/`, `lib/features/profile/`
- Orang 3: `lib/features/project/`, `lib/features/password/`

File bersama yang tidak boleh diubah sembarangan, kabari grup dulu: `main.dart`, `router.dart`, `theme.dart`, `pubspec.yaml`, dan folder `core/models/`.

Kalau menambah paket lewat `flutter pub add`, merge secepatnya dan umumkan di grup supaya yang lain menjalankan `flutter pub get`.

## 7. Kalau terjadi konflik

Konflik muncul kalau dua orang mengubah baris yang sama. Cara mengatasinya:

1. Di branch fiturmu, jalankan `git pull origin develop`
2. Buka file yang bertanda konflik. Kamu akan melihat:
```
<<<<<<< HEAD
kode versimu
=======
kode versi teman
>>>>>>> origin/develop
```
3. Pilih atau gabungkan kode yang benar, lalu hapus tiga baris penanda (`<<<<<<<`, `=======`, `>>>>>>>`)
4. Simpan, lalu:
```bash
git add .
git commit -m "fix: selesaikan konflik dengan develop"
git push
```
Android Studio juga punya jendela bantu: klik kanan file konflik, pilih **Git**, lalu **Resolve Conflicts**. Kalau ragu, tanya di grup sebelum menghapus kode orang lain.

## 8. Kesalahan umum dan solusinya

**Lupa `git pull` sebelum mulai**
Di branch fiturmu jalankan `git pull origin develop`.

**Terlanjur mengubah file di `develop` (belum commit)**
```bash
git checkout -b feature/nama-fitur
```
Perubahanmu ikut terbawa ke branch baru.

**Terlanjur commit di `develop` (belum push)**
```bash
git checkout -b feature/nama-fitur
git checkout develop
git reset --hard origin/develop
```
Commit-nya aman di branch fitur. Perintah `reset --hard` menghapus perubahan lokal yang belum di-commit, jadi pastikan semuanya sudah ter-commit dulu.

**Ingin membatalkan perubahan di satu file yang belum di-commit**
```bash
git restore nama_file.dart
```

**Mau pindah branch tapi ada perubahan yang belum selesai**
```bash
git stash
git checkout nama-branch
git stash pop
```

**Salah nama branch atau pesan commit terakhir salah (belum push)**
```bash
git commit --amend -m "pesan yang benar"
```

**Push ditolak karena branch tertinggal**
```bash
git pull origin develop
git push
```

**Setelah pull, aplikasi error aneh**
Jalankan `flutter pub get`, lalu `flutter clean` dan `flutter run` kalau masih error.

## 9. Keamanan

- Repo harus **Private**
- URL dan anon key Supabase boleh ada di `lib/core/supabase_config.dart`
- **`service_role` key tidak boleh di-commit atau dibagikan di grup**, karena melewati semua aturan akses database
- Jangan commit file pribadi atau data yang tidak perlu (folder `build/` dan `.dart_tool/` sudah diabaikan lewat `.gitignore`)

## 10. Ringkasan satu layar

```bash
git checkout develop
git pull origin develop
git checkout -b feature/nama-fitur
# kerjakan...
git add .
git commit -m "feat: deskripsi singkat"
git push -u origin feature/nama-fitur
# lalu buat Pull Request ke develop di GitHub
```
