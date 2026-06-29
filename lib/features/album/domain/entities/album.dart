class Album {
  final String id;
  final String title;
  final String artistId;
  final String coverUrl;
  final int releaseYear;
  final DateTime createdAt;

  Album({
    required this.id,
    required this.title,
    required this.artistId,
    required this.coverUrl,
    required this.releaseYear,
    required this.createdAt,
  });
}
