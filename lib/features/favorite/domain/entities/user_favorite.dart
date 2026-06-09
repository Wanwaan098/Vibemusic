class UserFavorite {
  final String id;
  final String userId;
  final List<String> songIds; // List of song IDs marked as favorite
  final DateTime updatedAt;

  UserFavorite({
    required this.id,
    required this.userId,
    required this.songIds,
    required this.updatedAt,
  });
}
