import 'models/project.dart';
import 'models/task.dart';

final dummyProjects = <Project>[
  Project(
    id: 'p1',
    name: 'Tugas Besar Mobile',
    description: 'Aplikasi Flutter kelompok',
    inviteCode: 'AB12CD',
    dueDate: DateTime(2026, 12, 20),
    tasks: const [
      Task(id: 't1', projectId: 'p1', title: 'Desain UI', status: TaskStatus.completed),
      Task(id: 't2', projectId: 'p1', title: 'Backend', status: TaskStatus.inProgress),
      Task(id: 't3', projectId: 'p1', title: 'Laporan', status: TaskStatus.todo),
    ],
  ),
  Project(
    id: 'p2',
    name: 'Riset Kelompok',
    inviteCode: 'ZX98YU',
    status: 'completed',
    tasks: const [
      Task(id: 't4', projectId: 'p2', title: 'Wawancara', status: TaskStatus.completed),
    ],
  ),
];