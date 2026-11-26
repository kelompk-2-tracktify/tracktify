import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/primary_button.dart';

class EmptyTaskState extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;
  const EmptyTaskState({super.key, required this.onCreate, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                color: Color(0xFFDCE6FA), shape: BoxShape.circle),
            child: const Icon(Icons.assignment_outlined, color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          const Text('No task yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            "Create your first task or join a project\nwith a team leader's code.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7686)),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Create New Task', onPressed: onCreate),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEFF3F7),
                foregroundColor: AppColors.text,
                shape: const StadiumBorder(),
              ),
              onPressed: onJoin,
              icon: const Icon(Icons.group_add_outlined, size: 18),
              label: const Text('Join Project',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}