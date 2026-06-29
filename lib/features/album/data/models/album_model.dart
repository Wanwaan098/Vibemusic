import 'package:music_app/features/album/domain/entities/album.dart';

class AlbumModel extends Album {
  AlbumModel({
    required super.id,
    required super.title,
    required super.artistId,
    required super.coverUrl,
    required super.releaseYear,
    required super.createdAt,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artist_id'] as String,
      coverUrl: json['cover_url'] as String,
      releaseYear: json['release_year'] as int,
      createdAt: (json['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_id': artistId,
      'cover_url': coverUrl,
      'release_year': releaseYear,
      'created_at': createdAt,
    };
  }
}
