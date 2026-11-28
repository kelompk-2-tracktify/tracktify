import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tracktify/core/models/project.dart';

class ProjectRepository {
  final SupabaseClient _client;

  ProjectRepository(this._client);

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Please sign in to continue.');
    return user.id;
  }

  Future<List<Map<String, dynamic>>> searchProfilesByEmail(String query) async {
    final term = query.trim();
    if (term.length < 3) return [];
    final literal = term.replaceAllMapped(
      RegExp(r'[\\%_*]'),
      (match) => '\\${match[0]}',
    );
    return await _client
        .from('profiles')
        .select('id, full_name, email, avatar_url')
        .ilike('email', '%$literal%')
        .neq('id', _currentUserId)
        .order('email', ascending: true)
        .order('id', ascending: true)
        .limit(20);
  }

  /// Mengirim judul subtask sesuai urutan pada form dan mengembalikan UUID proyek.
  Future<String> createProject({
    required String name,
    String? description,
    DateTime? dueDate,
    List<String> memberIds = const [],
    List<String> subtasks = const [],
  }) async {
    final otherMembers = memberIds.toSet()..remove(_currentUserId);
    return await _client.rpc<String>(
      'create_project_with_details',
      params: {
        'p_name': name.trim(),
        'p_description': description?.trim(),
        'p_due_date': dueDate?.toIso8601String().substring(0, 10),
        'p_member_ids': otherMembers.toList(),
        'p_subtasks': subtasks,
      },
    );
  }

  Future<List<Project>> fetchMyProjects() async {
    final rows = await _client
        .from('projects')
        .select(
          '*, tasks(*), my_membership:project_members!inner(user_id), '
          'project_members(project_id, user_id, role, profiles(full_name, avatar_url))',
        )
        .eq('my_membership.user_id', _currentUserId)
        .order('role', ascending: true, referencedTable: 'project_members')
        .order('user_id', referencedTable: 'project_members')
        .order('created_at', ascending: false);
    return rows.map(Project.fromJson).toList();
  }
}

final projectRepositoryProvider = Provider(
  (ref) => ProjectRepository(Supabase.instance.client),
);
