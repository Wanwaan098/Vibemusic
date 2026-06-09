import 'package:flutter/material.dart';
import 'package:music_app/features/playlist/domain/entities/playlist.dart';
import 'package:music_app/features/playlist/domain/usecases/playlist_usecases.dart';

class PlaylistProvider extends ChangeNotifier {
  final GetPlaylistsByUser getPlaylistsByUser;
  final CreatePlaylist createPlaylist;
  final AddSongToPlaylist addSongToPlaylist;
  final RemoveSongFromPlaylist removeSongFromPlaylist;
  final DeletePlaylist deletePlaylist;

  PlaylistProvider({
    required this.getPlaylistsByUser,
    required this.createPlaylist,
    required this.addSongToPlaylist,
    required this.removeSongFromPlaylist,
    required this.deletePlaylist,
  });

  List<Playlist> playlists = [];
  bool isLoading = false;

  Future<void> loadPlaylists(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      playlists = await getPlaylistsByUser(userId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createNewPlaylist(String userId, String name) async {
    try {
      final newPlaylist = Playlist(
        id: DateTime.now().toString(),
        userId: userId,
        name: name,
        songIds: [],
        createdAt: DateTime.now(),
      );

      await createPlaylist(newPlaylist);
      await loadPlaylists(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSongToPlaylistLocal(String playlistId, String songId) async {
    try {
      await addSongToPlaylist(playlistId, songId);

      final index = playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1 && !playlists[index].songIds.contains(songId)) {
        playlists[index].songIds.add(songId);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlaylistLocal(String playlistId) async {
    try {
      await deletePlaylist(playlistId);
      playlists.removeWhere((p) => p.id == playlistId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
