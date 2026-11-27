import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracktify/app/theme.dart';
import 'package:tracktify/core/models/project.dart';
import 'package:tracktify/core/widgets/project_card.dart';
import 'package:tracktify/features/task_list/empty_task_state.dart';
import 'package:tracktify/features/task_list/task_list_providers.dart';

enum TimeFilter { all, today, week, month }

const _timeLabels = {
  TimeFilter.all: 'All Time',
  TimeFilter.today: 'Today',
  TimeFilter.week: 'This Week',
  TimeFilter.month: 'This Month',
};

const _statusFilters = {
  'all': 'All',
  'in_progress': 'In Progress',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
};

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  String _query = '';
  String _status = 'all';
  TimeFilter _time = TimeFilter.all;

  bool _matchesTime(Project p) {
    if (_time == TimeFilter.all) return true;
    final d = p.dueDate;
    if (d == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(d.year, d.month, d.day);
    switch (_time) {
      case TimeFilter.today:
        return due == today;
      case TimeFilter.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return !due.isBefore(start) && due.isBefore(end);
      case TimeFilter.month:
        return due.year == today.year && due.month == today.month;
      case TimeFilter.all:
        return true;
    }
  }

  List<Project> _filter(List<Project> all) {
    final q = _query.trim().toLowerCase();
    return all.where((p) {
      final okStatus = _status == 'all' || p.status == _status;
      final okSearch =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.tasks.any((t) => t.title.toLowerCase().contains(q));
      return okStatus && okSearch && _matchesTime(p);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final all = projects.asData?.value;
    final shown = all == null ? const <Project>[] : _filter(all);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text(
              'Task List',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search title or task name...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final e in _statusFilters.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _status == e.key,
                        showCheckmark: false,
                        selectedColor: AppColors.navy,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: _status == e.key
                              ? Colors.white
                              : AppColors.text,
                        ),
                        onSelected: (_) => setState(() => _status = e.key),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 8),
                PopupMenuButton<TimeFilter>(
                  onSelected: (v) => setState(() => _time = v),
                  itemBuilder: (_) => [
                    for (final e in _timeLabels.entries)
                      CheckedPopupMenuItem(
                        value: e.key,
                        checked: _time == e.key,
                        child: Text(e.value),
                      ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _timeLabels[_time]!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (all?.isNotEmpty == true)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      shape: const StadiumBorder(),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => context.push('/join'),
                    icon: const Icon(Icons.group_add_outlined, size: 16),
                    label: const Text(
                      'Join Task',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (projects.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (projects.hasError)
              Column(
                children: [
                  const Text('Daftar proyek gagal dimuat.'),
                  TextButton(
                    onPressed: () => ref.invalidate(projectsProvider),
                    child: const Text('Coba lagi'),
                  ),
                ],
              )
            else if (all!.isEmpty)
              EmptyTaskState(
                onCreate: () => context.push('/manage-task'),
                onJoin: () => context.push('/join'),
              )
            else if (shown.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Tidak ada task yang cocok',
                    style: TextStyle(color: Color(0xFF6B7686)),
                  ),
                ),
              )
            else
              for (final p in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectCard(
                    project: p,
                    onTap: () => context.push('/project/${p.id}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
