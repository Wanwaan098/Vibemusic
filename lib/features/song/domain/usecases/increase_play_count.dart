import 'package:music_app/features/song/domain/repositories/song_repository.dart';

class IncreasePlayCount {
  final SongRepository repository;

  IncreasePlayCount(this.repository);

  Future<void> call(String id) {
    return repository.increasePlayCount(id);
  }
}
