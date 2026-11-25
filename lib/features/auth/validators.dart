String? validateName(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null;

String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Format email tidak valid';
}

String? validatePassword(String? v) =>
    (v == null || v.length < 6) ? 'Minimal 6 karakter' : null;