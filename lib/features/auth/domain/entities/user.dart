class UserEntity {
  final String uid;
  final String email;
  final String role;
  final String? name;
  final String? avatarUrl;

  UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.avatarUrl,
  });
}
