import 'package:music_app/features/song/domain/entities/lyric_line.dart';

class Song {
  final String id;
  final String title;
  final String titleLowercase;
  final String artistId;
  final String artistName;
  final String? albumId;
  final String genre;
  final String audioUrl;
  final String coverUrl;

  final String lyricRaw;
  final Map<String, dynamic> lyricMeta;
  final List<LyricLine> lyricLines;

  final int duration;
  final int playCount;

  final DateTime releaseDate;
  final DateTime createdAt;

  Song({
    required this.id,
    required this.title,
    required this.titleLowercase,
    required this.artistId,
    required this.artistName,
    this.albumId,
    required this.genre,
    required this.audioUrl,
    required this.coverUrl,
    required this.lyricRaw,
    required this.lyricMeta,
    required this.lyricLines,
    required this.duration,
    required this.playCount,
    required this.releaseDate,
    required this.createdAt,
  });
}