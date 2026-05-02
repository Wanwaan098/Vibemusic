import '../entities/song.dart';
import '../repositories/song_repository.dart';

class GetSongs {
  final SongRepository repository;

  GetSongs(this.repository);

  Future<List<Song>> call() => repository.getSongs();
}