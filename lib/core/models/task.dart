class TaskStatus {
  static const todo = 'todo';
  static const inProgress = 'in_progress';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

class Task {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String status;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'],
    projectId: j['project_id'],
    title: j['title'],
    description: j['description'],
    status: j['status'],
  );

  Map<String, dynamic> toInsertJson() => {
    'project_id': projectId,
    'title': title,
    'description': description,
    'status': status,
  };
}