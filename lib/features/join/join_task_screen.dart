import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracktify/app/theme.dart';
import 'package:tracktify/core/widgets/primary_button.dart';
import 'package:tracktify/features/join/join_models.dart';
import 'package:tracktify/features/join/join_providers.dart';

class JoinTaskScreen extends ConsumerStatefulWidget {
  const JoinTaskScreen({super.key});

  @override
  ConsumerState<JoinTaskScreen> createState() => _JoinTaskScreenState();
}

class _JoinTaskScreenState extends ConsumerState<JoinTaskScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _send() {
    final error = ref.read(joinProvider.notifier).sendRequest(_codeCtrl.text);
    if (error != null) {
      _snack(error);
    } else {
      _codeCtrl.clear();
      FocusScope.of(context).unfocus();
      _snack('Request terkirim, tunggu persetujuan leader');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(joinProvider);
    final notifier = ref.read(joinProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Join Task',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (s.invitations.isNotEmpty) ...[
            Row(
              children: [
                const Text('Direct Invitations',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                _Badge(
                  label: '${s.invitations.length} new',
                  bg: const Color(0xFFDCE6FA),
                  fg: AppColors.navy,
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final inv in s.invitations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InvitationCard(
                  invitation: inv,
                  onDecline: () {
                    notifier.declineInvitation(inv.id);
                    _snack('Undangan ditolak');
                  },
                  onAccept: () {
                    notifier.acceptInvitation(inv.id);
                    _snack('Berhasil bergabung ke ${inv.projectName}');
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
          const Text('Join with Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _Box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Project Invite Code',
                    style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'E.G.: KLP-89A',
                    prefixIcon: Icon(Icons.vpn_key_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(label: 'Send Join Request', onPressed: _send),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final p in s.pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingCard(
                join: p,
                onCancel: () {
                  notifier.cancelRequest(p.id);
                  _snack('Request dibatalkan');
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final Widget child;
  const _Box({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.fieldBorder),
    ),
    child: child,
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;
  const _Badge(
      {required this.label, required this.bg, required this.fg, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration:
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
        ],
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      ],
    ),
  );
}

class _InvitationCard extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  const _InvitationCard({
    required this.invitation,
    required this.onDecline,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(invitation.projectName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const _Badge(
                label: 'Direct',
                bg: Color(0xFFD6F5EC),
                fg: Color(0xFF1B7A43),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Invited by ${invitation.invitedBy} (Leader)',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7686))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.fieldBorder),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onDecline,
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onAccept,
                  child: const Text('Accept & Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PendingJoin join;
  final VoidCallback onCancel;
  const _PendingCard({required this.join, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(join.projectName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const _Badge(
                label: 'Pending',
                bg: Color(0xFFFDEFC3),
                fg: Color(0xFF8A5A00),
                icon: Icons.hourglass_bottom,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Code: ${join.code}',
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Color(0xFF6B7686))),
          const SizedBox(height: 6),
          const Text(
            "Your request has been sent. You'll be added automatically once the group leader approves.",
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7686)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE6ECF2)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onCancel,
              child: const Text('Cancel Request',
                  style: TextStyle(
                      color: Color(0xFFB3261E), fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}