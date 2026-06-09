class Playlist {
  final String id;
  final String userId;
  final String name;
  final String? thumbnailUrl;
  final List<String> songIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.thumbnailUrl,
    required this.songIds,
    required this.createdAt,
  });
}
