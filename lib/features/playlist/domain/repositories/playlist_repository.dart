import 'package:music_app/features/playlist/domain/entities/playlist.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getPlaylistsByUser(String userId);
  Future<Playlist> getPlaylist(String playlistId);
  Future<void> createPlaylist(Playlist playlist);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
}
