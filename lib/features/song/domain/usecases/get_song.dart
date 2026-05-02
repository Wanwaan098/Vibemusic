import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/repositories/song_repository.dart';

class GetSong {
  final SongRepository repository;

  GetSong(this.repository);

  Future<Song> call(String id) => repository.getSong(id);
}
