import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/repositories/song_repository.dart';

class UpdateSong {
  final SongRepository repository;

  UpdateSong(this.repository);

  Future<void> call(Song song) => repository.updateSong(song);
}