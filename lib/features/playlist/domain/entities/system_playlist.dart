class SystemPlaylist {
  final String id;
  final String name;
  final String description;
  final bool isSystem;
  final String thumbnail;
  final int priority;
  final int songCount;
  final List<String> songIds;
  final DateTime createdAt;

  SystemPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.isSystem,
    required this.thumbnail,
    required this.priority,
    required this.songCount,
    required this.songIds,
    required this.createdAt,
  });
}
