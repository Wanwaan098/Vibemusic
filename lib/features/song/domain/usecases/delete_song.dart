import 'package:music_app/features/song/domain/repositories/song_repository.dart';

class DeleteSong {
  final SongRepository repository;

  DeleteSong(this.repository);

  Future<void> call(String id) => repository.deleteSong(id);
}