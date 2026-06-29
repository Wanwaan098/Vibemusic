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

  Playlist copyWith({
    String? id,
    String? userId,
    String? name,
    String? thumbnailUrl,
    List<String>? songIds,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      songIds: songIds ?? List<String>.from(this.songIds),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
