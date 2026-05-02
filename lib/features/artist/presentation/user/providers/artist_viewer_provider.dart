import 'package:flutter/material.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/usecases/get_artist.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/usecases/get_songs.dart';

class ArtistViewerProvider extends ChangeNotifier {
  final GetArtist getArtist;
  final GetSongs getSongs;

  ArtistViewerProvider({required this.getArtist, required this.getSongs});

  Artist? currentArtist;
  List<Song> artistSongs = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadArtistDetail(String artistId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('🎨 Loading artist $artistId...');

      // Load artist info
      final artist = await getArtist(artistId).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Artist load timeout'),
      );
      print('✅ Artist loaded: ${artist.name}');
      currentArtist = artist;

      // Load all songs and filter by artist
      final allSongs = await getSongs().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Songs load timeout'),
      );
      print('✅ All songs loaded: ${allSongs.length} total');

      artistSongs = allSongs
          .where((song) => song.artistId == artistId)
          .toList();
      print('✅ Filtered ${artistSongs.length} songs for artist $artistId');

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading artist detail: $e');
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
