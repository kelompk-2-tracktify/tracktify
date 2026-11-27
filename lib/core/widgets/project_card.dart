import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../models/project.dart';
import '../models/member.dart';
import '../models/task.dart';
import 'progress_ring.dart';

class _StatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final Color ring;
  const _StatusStyle(this.label, this.bg, this.fg, this.ring);
}

_StatusStyle _styleFor(String status) {
  switch (status) {
    case 'completed':
      return const _StatusStyle(
        'Completed',
        Color(0xFFD9F5E3),
        Color(0xFF1B7A43),
        Color(0xFF1E8E4A),
      );
    case 'cancelled':
      return const _StatusStyle(
        'Cancelled',
        Color(0xFFFADADD),
        Color(0xFFB3261E),
        Color(0xFFB3261E),
      );
    default:
      return const _StatusStyle(
        'In Progress',
        Color(0xFFFDEFC3),
        Color(0xFF8A5A00),
        AppColors.navy,
      );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;

  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(project.status);
    final description = project.description?.trim() ?? '';
    final done = project.tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final total = project.tasks.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProgressRing(value: project.progress, color: style.ring),
                ],
              ),
              Row(
                children: [
                  if (description.isNotEmpty) ...[
                    Flexible(
                      child: Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7686),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _StatusChip(style: style),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Tim',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final member in project.members.take(3))
                    _MemberAvatar(key: ValueKey(member.userId), member: member),
                  const CircleAvatar(
                    radius: 13,
                    backgroundColor: Color(0xFFD6F5EC),
                    child: Icon(Icons.add, size: 16, color: Color(0xFF1B7A43)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE6ECF2)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Color(0xFF6B7686),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    project.dueDate == null
                        ? 'Tanpa tenggat'
                        : DateFormat('d MMM yyyy').format(project.dueDate!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7686),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.check_box_outlined,
                    size: 14,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$done/$total Subtugas',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7686),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _StatusStyle style;
  const _StatusChip({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: style.fg,
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final Member member;
  const _MemberAvatar({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member.fullName?.trim() ?? '';
    final words = name.split(RegExp(r'\s+'));
    final initials = words.length == 1
        ? name.characters.take(2).toString()
        : words.first.characters.first + words.last.characters.first;
    final uri = Uri.tryParse(member.avatarUrl?.trim() ?? '');
    final hasPhoto =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    return Semantics(
      label: name.isEmpty ? 'Anggota' : name,
      excludeSemantics: true,
      child: CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFDCE6FA),
        foregroundColor: AppColors.navy,
        child: ClipOval(
          child: SizedBox.expand(
            child: hasPhoto
                ? Image.network(
                    uri.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _initialsLabel(initials),
                  )
                : _initialsLabel(initials),
          ),
        ),
      ),
    );
  }

  Widget _initialsLabel(String initials) => Center(
    child: Text(
      initials.isEmpty ? '?' : initials.toUpperCase(),
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}
