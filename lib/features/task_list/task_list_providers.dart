import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracktify/core/models/project.dart';
import 'package:tracktify/features/auth/auth_repository.dart';
import 'package:tracktify/features/project/project_repository.dart';

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return const <Project>[];
  return repository.fetchMyProjects();
}, retry: (_, _) => null);
