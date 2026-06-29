import 'package:flutter/material.dart';
import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';
import 'package:music_app/features/playlist/domain/usecases/system_playlist_usecases.dart';

class SystemPlaylistProvider extends ChangeNotifier {
  final GetSystemPlaylists getSystemPlaylists;
  final CreateSystemPlaylist createSystemPlaylist;
  final UpdateSystemPlaylist updateSystemPlaylist;
  final DeleteSystemPlaylist deleteSystemPlaylist;
  final AddSongToSystemPlaylist addSongToSystemPlaylist;
  final RemoveSongFromSystemPlaylist removeSongFromSystemPlaylist;

  List<SystemPlaylist> _playlists = [];
  bool _isLoading = false;
  String? _error;

  SystemPlaylistProvider({
    required this.getSystemPlaylists,
    required this.createSystemPlaylist,
    required this.updateSystemPlaylist,
    required this.deleteSystemPlaylist,
    required this.addSongToSystemPlaylist,
    required this.removeSongFromSystemPlaylist,
  });

  List<SystemPlaylist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Hàm helper để gọi data và sort, không đụng tới isLoading
  Future<void> _fetchAndSortPlaylists() async {
    final result = await getSystemPlaylists();
    result.sort((a, b) => a.priority.compareTo(b.priority));
    _playlists = result;
  }

  Future<void> loadPlaylists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fetchAndSortPlaylists();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPlaylist({
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await createSystemPlaylist(
        name: name,
        description: description,
        thumbnail: thumbnail,
        priority: priority,
        songIds: songIds,
      );
      // Lấy lại danh sách ngay sau khi tạo
      await _fetchAndSortPlaylists();
    } catch (e) {
      _error = e.toString();
      rethrow; // Ném lỗi ra để UI bắt được (đã được bắt ở catch UI)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlaylist({
    required String id,
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await updateSystemPlaylist(
        id: id,
        name: name,
        description: description,
        thumbnail: thumbnail,
        priority: priority,
        songIds: songIds,
      );
      await _fetchAndSortPlaylists();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removePlaylist(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await deleteSystemPlaylist(id);
      await _fetchAndSortPlaylists();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSong(String playlistId, String songId) async {
    try {
      await addSongToSystemPlaylist(playlistId, songId);
      await _fetchAndSortPlaylists();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeSong(String playlistId, String songId) async {
    try {
      await removeSongFromSystemPlaylist(playlistId, songId);
      await _fetchAndSortPlaylists();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}