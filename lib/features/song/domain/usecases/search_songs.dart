import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/repositories/song_repository.dart';

class SearchSongs {
  final SongRepository repository;

  SearchSongs(this.repository);

  Future<List<Song>> call(String query) {
    return repository.searchSongs(query.toLowerCase());
  }
}