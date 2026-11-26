import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracktify/features/join/join_models.dart';

class JoinState {
  final List<ProjectInvitation> invitations;
  final List<PendingJoin> pending;
  const JoinState({this.invitations = const [], this.pending = const []});

  JoinState copyWith({
    List<ProjectInvitation>? invitations,
    List<PendingJoin>? pending,
  }) =>
      JoinState(
        invitations: invitations ?? this.invitations,
        pending: pending ?? this.pending,
      );
}

/// DUMMY: kode yang dianggap valid. Nanti dicek ke database.
const _knownCodes = {
  'KLP-89A': 'Tugas Besar Mobile',
  'ABC-123': 'Riset Kelompok',
};

/// Semua aksi ada di sini. Nanti isi method diganti memanggil
/// join_repository, layar tidak perlu diubah.
class JoinNotifier extends Notifier<JoinState> {
  @override
  JoinState build() => const JoinState(
    invitations: [
      ProjectInvitation(
        id: 'i1',
        projectName: 'Tugas Besar Basis Data',
        invitedBy: 'Raka Pratama',
      ),
    ],
    pending: [
      PendingJoin(
        id: 'r1',
        projectName: 'Tugas Besar Mobile',
        code: 'KLP-89A',
      ),
    ],
  );

  /// Mengembalikan pesan error, atau null kalau berhasil.
  String? sendRequest(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return 'Kode tidak boleh kosong';
    if (state.pending.any((p) => p.code == code)) {
      return 'Request untuk project ini sudah dikirim';
    }
    final name = _knownCodes[code];
    if (name == null) return 'Kode tidak ditemukan';
    state = state.copyWith(pending: [
      ...state.pending,
      PendingJoin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectName: name,
        code: code,
      ),
    ]);
    return null;
  }

  void cancelRequest(String id) {
    state = state.copyWith(
      pending: state.pending.where((p) => p.id != id).toList(),
    );
  }

  void acceptInvitation(String id) => _removeInvitation(id);
  void declineInvitation(String id) => _removeInvitation(id);

  void _removeInvitation(String id) {
    state = state.copyWith(
      invitations: state.invitations.where((i) => i.id != id).toList(),
    );
  }
}

final joinProvider =
NotifierProvider<JoinNotifier, JoinState>(JoinNotifier.new);