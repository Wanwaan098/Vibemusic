import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';

abstract class SystemPlaylistRepository {
  Future<List<SystemPlaylist>> getSystemPlaylists();
  Future<void> createSystemPlaylist({
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  });
  Future<void> updateSystemPlaylist({
    required String id,
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  });
  Future<void> deleteSystemPlaylist(String id);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
}
