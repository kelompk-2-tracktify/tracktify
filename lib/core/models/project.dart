import 'member.dart';
import 'task.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final String inviteCode;
  final DateTime? dueDate;
  final String status;
  final String? createdBy;
  final List<Task> tasks; // terisi bila query: select('*, tasks(*)')
  final List<Member> members;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.inviteCode,
    this.dueDate,
    this.status = 'in_progress',
    this.createdBy,
    this.tasks = const [],
    this.members = const [],
  });

  /// Progress 0.0 - 1.0, dihitung dari subtask completed (tidak disimpan di DB)
  double get progress {
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => t.status == TaskStatus.completed).length;
    return done / tasks.length;
  }

  factory Project.fromJson(Map<String, dynamic> j) => Project(
    id: j['id'],
    name: j['name'],
    description: j['description'],
    inviteCode: j['invite_code'],
    dueDate: j['due_date'] == null ? null : DateTime.parse(j['due_date']),
    status: j['status'],
    createdBy: j['created_by'],
    members: (j['project_members'] as List? ?? [])
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList(),
    tasks: (j['tasks'] as List? ?? [])
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// invite_code dan created_by diisi otomatis oleh database
  Map<String, dynamic> toInsertJson() => {
    'name': name,
    'description': description,
    'due_date': dueDate?.toIso8601String().substring(0, 10),
    'status': status,
  };
}
