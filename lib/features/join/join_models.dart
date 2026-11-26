/// project_invitations dan join_requests.
class ProjectInvitation {
  final String id;
  final String projectName;
  final String invitedBy;
  const ProjectInvitation({
    required this.id,
    required this.projectName,
    required this.invitedBy,
  });
}

class PendingJoin {
  final String id;
  final String projectName;
  final String code;
  const PendingJoin({
    required this.id,
    required this.projectName,
    required this.code,
  });
}