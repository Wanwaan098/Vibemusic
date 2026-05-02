import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/lyric_line.dart';

class SongModel extends Song {
  SongModel({
    required super.id,
    required super.title,
    required super.titleLowercase,
    required super.artistId,
    required super.artistName,
    super.albumId,
    required super.genre,
    required super.audioUrl,
    required super.coverUrl,
    required super.lyricRaw,
    required super.lyricMeta,
    required super.lyricLines,
    required super.duration,
    required super.playCount,
    required super.releaseDate,
    required super.createdAt,
  });

  factory SongModel.fromJson(String id, Map<String, dynamic> json) {
    return SongModel(
      id: id,
      title: json['title'] ?? '',
      titleLowercase: json['title_lowercase'] ?? '',
      artistId: json['artist_id'] ?? '',
      artistName: json['artist_name'] ?? '',
      albumId: json['album_id'],
      genre: json['genre'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      coverUrl: json['cover_url'] ?? '',
      lyricRaw: json['lyric_raw'] ?? '',
      lyricMeta: json['lyric_meta'] != null
          ? Map<String, dynamic>.from(json['lyric_meta'])
          : {},
      lyricLines: (json['lyric_lines'] as List?)
              ?.map((e) => LyricLine.fromJson(e))
              .toList() ??
          [],
      duration: json['duration'] ?? 0,
      playCount: json['play_count'] ?? 0,
      releaseDate: _parseTimestamp(json['release_date']),
      createdAt: _parseTimestamp(json['created_at']),
    );
  }

  factory SongModel.fromEntity(Song song) {
    return SongModel(
      id: song.id,
      title: song.title,
      titleLowercase: song.titleLowercase,
      artistId: song.artistId,
      artistName: song.artistName,
      albumId: song.albumId,
      genre: song.genre,
      audioUrl: song.audioUrl,
      coverUrl: song.coverUrl,
      lyricRaw: song.lyricRaw,
      lyricMeta: song.lyricMeta,
      lyricLines: song.lyricLines,
      duration: song.duration,
      playCount: song.playCount,
      releaseDate: song.releaseDate,
      createdAt: song.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "title_lowercase": titleLowercase,
      "artist_id": artistId,
      "artist_name": artistName,
      "album_id": albumId,
      "genre": genre,
      "audio_url": audioUrl,
      "cover_url": coverUrl,
      "lyric_raw": lyricRaw,
      "lyric_meta": lyricMeta,
      "lyric_lines": lyricLines.map((e) => e.toJson()).toList(),
      "duration": duration,
      "play_count": playCount,
      "release_date": Timestamp.fromDate(releaseDate),
      "created_at": Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}