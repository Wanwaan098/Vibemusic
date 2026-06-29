class AdminStats {
  final int totalSongs;
  final int totalAlbums;
  final int totalArtists;
  final List<TopSong> topSongs;
  final Map<String, int>? distribution; // optional (genre -> count)

  AdminStats({
    required this.totalSongs,
    required this.totalAlbums,
    required this.totalArtists,
    required this.topSongs,
    this.distribution,
  });
}

class TopSong {
  final String id;
  final String title;
  final String artistName;
  final String? thumbnailUrl;
  final int playCount;

  TopSong({
    required this.id,
    required this.title,
    required this.artistName,
    this.thumbnailUrl,
    required this.playCount,
  });
}
