class JoinRequest {
  final String id;
  final String projectId;
  final String userId;
  final String status; // pending | approved | declined
  final String? fullName;
  final String? projectName;

  const JoinRequest({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.status,
    this.fullName,
    this.projectName,
  });

  // query admin: select('*, profiles(full_name)')
  factory JoinRequest.fromJson(Map<String, dynamic> j) => JoinRequest(
    id: j['id'],
    projectId: j['project_id'],
    userId: j['user_id'] ?? '',
    status: j['status'],
    fullName: j['profiles']?['full_name'],
    projectName: j['project_name'],
  );
}