import 'package:music_app/features/playlist/data/datasources/system_playlist_remote_data_source.dart';
import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';
import 'package:music_app/features/playlist/domain/repositories/system_playlist_repository.dart';

class SystemPlaylistRepositoryImpl implements SystemPlaylistRepository {
  final SystemPlaylistRemoteDataSource remoteDataSource;

  SystemPlaylistRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SystemPlaylist>> getSystemPlaylists() async {
    return await remoteDataSource.getSystemPlaylists();
  }

  @override
  Future<void> createSystemPlaylist({
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    await remoteDataSource.createSystemPlaylist(
      name: name,
      description: description,
      thumbnail: thumbnail,
      priority: priority,
      songIds: songIds,
    );
  }

  @override
  Future<void> updateSystemPlaylist({
    required String id,
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    await remoteDataSource.updateSystemPlaylist(
      id: id,
      name: name,
      description: description,
      thumbnail: thumbnail,
      priority: priority,
      songIds: songIds,
    );
  }

  @override
  Future<void> deleteSystemPlaylist(String id) async {
    await remoteDataSource.deleteSystemPlaylist(id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await remoteDataSource.addSongToPlaylist(playlistId, songId);
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await remoteDataSource.removeSongFromPlaylist(playlistId, songId);
  }
}
