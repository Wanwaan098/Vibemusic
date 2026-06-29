import 'package:music_app/features/admin/domain/entities/admin_stats.dart';
import 'package:music_app/features/song/domain/usecases/get_songs.dart';
import 'package:music_app/features/album/domain/usecases/get_albums.dart';
import 'package:music_app/features/artist/domain/usecases/get_artists.dart';

class AdminDataException implements Exception {
  final String message;
  AdminDataException(this.message);
}

class GetAdminStats {
  final GetSongs getSongs;
  final GetAlbums getAlbums;
  final GetArtists getArtists;

  GetAdminStats({
    required this.getSongs,
    required this.getAlbums,
    required this.getArtists,
  });

  /// Fetches data once and aggregates totals and top 5 songs.
  /// Throws [AdminDataException] on failures.
  Future<AdminStats> call() async {
    try {
      final songs = await getSongs();
      final albums = await getAlbums();
      final artists = await getArtists();

      final totalSongs = songs.length;
      final totalAlbums = albums.length;
      final totalArtists = artists.length;

      // determine top 5 by playCount (defensive: default 0)
      final sorted = List.of(songs);
      sorted.sort((a, b) => b.playCount.compareTo(a.playCount));
      final top = sorted.take(5).map((s) {
        String artistName = 'Unknown';
        try {
          final match = artists.firstWhere((a) => a.id == s.artistId);
          artistName = match.name;
        } catch (_) {
          // keep Unknown
        }
        return TopSong(
          id: s.id,
          title: s.title,
          artistName: artistName,
          thumbnailUrl: s.coverUrl,
          playCount: s.playCount,
        );
      }).toList();

      // optional distribution by genre if available on Song
      Map<String, int>? distribution;
      try {
        distribution = {};
        for (final s in songs) {
          final g = s.genre;
          distribution[g] = (distribution[g] ?? 0) + 1;
        }
      } catch (_) {
        distribution = null;
      }

      return AdminStats(
        totalSongs: totalSongs,
        totalAlbums: totalAlbums,
        totalArtists: totalArtists,
        topSongs: top,
        distribution: distribution,
      );
    } catch (e) {
      throw AdminDataException(
        'Không thể tải dữ liệu thống kê: ${e.toString()}',
      );
    }
  }
}
