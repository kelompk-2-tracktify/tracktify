class Member {
  final String projectId;
  final String userId;
  final String role; // 'admin' | 'member'
  final String? fullName;
  final String? avatarUrl;

  const Member({
    required this.projectId,
    required this.userId,
    required this.role,
    this.fullName,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'admin';

  // query: select('*, profiles(full_name, avatar_url)')
  factory Member.fromJson(Map<String, dynamic> j) => Member(
    projectId: j['project_id'],
    userId: j['user_id'],
    role: j['role'],
    fullName: j['profiles']?['full_name'],
    avatarUrl: j['profiles']?['avatar_url'],
  );
}