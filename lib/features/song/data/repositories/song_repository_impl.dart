import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/song_remote_data_source.dart';
import '../models/song_model.dart';

class SongRepositoryImpl implements SongRepository {
  final SongRemoteDataSource remote;

  SongRepositoryImpl(this.remote);

  @override
  Future<List<Song>> getSongs() => remote.getSongs();

  @override
  Future<Song> getSong(String id) => remote.getSong(id);

  @override
  Future<void> addSong(Song song) {
    return remote.addSong(SongModel.fromEntity(song));
  }

  @override
  Future<void> updateSong(Song song) {
    return remote.updateSong(SongModel.fromEntity(song));
  }

  @override
  Future<void> deleteSong(String id) {
    return remote.deleteSong(id);
  }

  @override
  Future<void> increasePlayCount(String id) {
    return remote.increasePlayCount(id);
  }

  @override
  Future<List<Song>> searchSongs(String query) {
    return remote.searchSongs(query);
  }
}