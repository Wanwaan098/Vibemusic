import 'package:flutter/material.dart';
import 'package:music_app/features/playlist/domain/entities/playlist.dart';
import 'package:music_app/features/playlist/domain/usecases/playlist_usecases.dart';

class PlaylistProvider extends ChangeNotifier {
  final GetPlaylistsByUser getPlaylistsByUser;
  final CreatePlaylist createPlaylist;
  final AddSongToPlaylist addSongToPlaylist;
  final RemoveSongFromPlaylist removeSongFromPlaylist;
  final DeletePlaylist deletePlaylist;
  final UpdatePlaylist updatePlaylist;

  PlaylistProvider({
    required this.getPlaylistsByUser,
    required this.createPlaylist,
    required this.addSongToPlaylist,
    required this.removeSongFromPlaylist,
    required this.deletePlaylist,
    required this.updatePlaylist,
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

      // Optimistic local update so the UI reflects the new playlist immediately
      final newList = List<Playlist>.from(playlists);
      newList.insert(0, newPlaylist);
      playlists = newList;
      notifyListeners();

      try {
        await createPlaylist(newPlaylist);
        // Refresh from backend to sync any server-generated fields
        await loadPlaylists(userId);
      } catch (e) {
        // revert local optimistic update
        playlists = playlists.where((p) => p.id != newPlaylist.id).toList();
        notifyListeners();
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSongToPlaylistLocal(
    String playlistId,
    String songId, {
    String? thumbnailUrl,
  }) async {
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final old = playlists[index];
    if (old.songIds.contains(songId)) return;

    final updated = old.copyWith(
      songIds: List<String>.from(old.songIds)..add(songId),
      thumbnailUrl: thumbnailUrl ?? old.thumbnailUrl,
    );

    // Optimistic local update
    final newList = List<Playlist>.from(playlists);
    newList[index] = updated;
    playlists = newList;
    notifyListeners();

    try {
      // Persist remote changes
      await addSongToPlaylist(playlistId, songId);
      if (thumbnailUrl != null) {
        await updatePlaylist(updated);
      }
    } catch (e) {
      // revert on failure
      final revertList = List<Playlist>.from(playlists);
      revertList[index] = old;
      playlists = revertList;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePlaylistLocal(String playlistId) async {
    // Optimistic removal
    final oldList = List<Playlist>.from(playlists);
    playlists = playlists.where((p) => p.id != playlistId).toList();
    notifyListeners();

    try {
      await deletePlaylist(playlistId);
    } catch (e) {
      // revert on failure
      playlists = oldList;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePlaylistNameLocal(
    String playlistId,
    String newName,
  ) async {
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final old = playlists[index];
    final updated = old.copyWith(name: newName);

    // Optimistic rename
    final newList = List<Playlist>.from(playlists);
    newList[index] = updated;
    playlists = newList;
    notifyListeners();

    try {
      await updatePlaylist(updated);
    } catch (e) {
      // revert on failure
      final revertList = List<Playlist>.from(playlists);
      revertList[index] = old;
      playlists = revertList;
      notifyListeners();
      rethrow;
    }
  }
}
