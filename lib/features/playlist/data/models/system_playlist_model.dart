import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';

class SystemPlaylistModel extends SystemPlaylist {
  SystemPlaylistModel({
    required super.id,
    required super.name,
    required super.description,
    required super.isSystem,
    required super.thumbnail,
    required super.priority,
    required super.songCount,
    required super.songIds,
    required super.createdAt,
  });

  factory SystemPlaylistModel.fromJson(Map<String, dynamic> json) {
    return SystemPlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isSystem: json['is_system'] as bool? ?? false,
      thumbnail: json['thumbnail'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
      songCount: json['song_count'] as int? ?? 0,
      songIds: List<String>.from(json['song_ids'] as List? ?? []),
      createdAt: (json['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_system': isSystem,
      'thumbnail': thumbnail,
      'priority': priority,
      'song_count': songCount,
      'song_ids': songIds,
      'created_at': createdAt,
    };
  }
}
