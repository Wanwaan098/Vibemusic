import 'package:music_app/features/playlist/data/datasources/playlist_remote_data_source.dart';
import 'package:music_app/features/playlist/domain/entities/playlist.dart';
import 'package:music_app/features/playlist/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _remoteDataSource;

  PlaylistRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Playlist>> getPlaylistsByUser(String userId) {
    return _remoteDataSource.getPlaylistsByUser(userId);
  }

  @override
  Future<Playlist> getPlaylist(String playlistId) {
    return _remoteDataSource.getPlaylist(playlistId);
  }

  @override
  Future<void> createPlaylist(Playlist playlist) {
    return _remoteDataSource.createPlaylist(playlist);
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) {
    return _remoteDataSource.updatePlaylist(playlist);
  }

  @override
  Future<void> deletePlaylist(String playlistId) {
    return _remoteDataSource.deletePlaylist(playlistId);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) {
    return _remoteDataSource.addSongToPlaylist(playlistId, songId);
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) {
    return _remoteDataSource.removeSongFromPlaylist(playlistId, songId);
  }
}
