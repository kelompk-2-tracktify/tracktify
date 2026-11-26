import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracktify/core/dummy_data.dart';
import 'package:tracktify/core/models/project.dart';

/// Daftar project milik pengguna.
/// SEKARANG: data dummy. NANTI (hari 4): ganti isi provider ini agar
/// memanggil project_repository, layar tidak perlu diubah.
/// Untuk tes empty state, ubah sementara jadi: return const <Project>[];
final projectsProvider = Provider<List<Project>>((ref) => dummyProjects);

/// Inisial anggota per project (dummy). Nanti dari tabel project_members.
final memberInitialsProvider = Provider.family<List<String>, String>((ref, id) {
  const data = {
    'p1': ['RP', 'SA', 'DW'],
    'p2': ['NP', 'BS'],
  };
  return data[id] ?? const [];
});