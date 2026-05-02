import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/repositories/song_repository.dart';

class AddSong {
  final SongRepository repository;

  AddSong(this.repository);

  Future<void> call(Song song) => repository.addSong(song);
}