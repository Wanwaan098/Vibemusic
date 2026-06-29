import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';
import 'package:music_app/features/song/domain/usecases/search_songs.dart';

enum SearchTab { all, songs, playlists, albums, artists }

class SearchProvider extends ChangeNotifier {
  final SearchSongs searchSongs;

  SearchProvider({required this.searchSongs});

  // ================= STATE =================
  String _searchQuery = '';
  SearchTab _selectedTab = SearchTab.all;
  bool _isLoading = false;
  List<String> _searchHistory = [];

  // ================= RESULTS =================
  List<Song> _searchedSongs = [];
  List<Artist> _searchedArtists = [];
  List<Album> _searchedAlbums = [];
  List<SystemPlaylist> _searchedPlaylists = [];

  // ================= DATA SOURCES =================
  List<Song> _allSongs = [];
  List<Artist> _allArtists = [];
  List<Album> _allAlbums = [];
  List<SystemPlaylist> _allPlaylists = [];

  // ================= GETTERS =================
  String get searchQuery => _searchQuery;
  SearchTab get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  List<String> get searchHistory => _searchHistory;

  List<Song> get searchedSongs => _searchedSongs;
  List<Artist> get searchedArtists => _searchedArtists;
  List<Album> get searchedAlbums => _searchedAlbums;
  List<SystemPlaylist> get searchedPlaylists => _searchedPlaylists;

  // ================= INIT =================
  Future<void> initialize() async {
    await _loadSearchHistory();
  }

  // ================= SET DATA SOURCES =================
  void setAllSongs(List<Song> songs) {
    _allSongs = List.from(songs);
    debugPrint('✅ SearchProvider.setAllSongs: ${_allSongs.length} songs');
    if (_allSongs.isNotEmpty) {
      debugPrint(
        '   First 3 songs: ${_allSongs.take(3).map((s) => "${s.title} - ${s.artistName}").join(" | ")}',
      );
    }
    notifyListeners();
  }

  void setAllArtists(List<Artist> artists) {
    _allArtists = List.from(artists);
    debugPrint('✅ SearchProvider.setAllArtists: ${_allArtists.length} artists');
    notifyListeners();
  }

  void setAllAlbums(List<Album> albums) {
    _allAlbums = List.from(albums);
    debugPrint('✅ SearchProvider.setAllAlbums: ${_allAlbums.length} albums');
    notifyListeners();
  }

  void setAllPlaylists(List<SystemPlaylist> playlists) {
    _allPlaylists = List.from(playlists);
    debugPrint(
      '✅ SearchProvider.setAllPlaylists: ${_allPlaylists.length} playlists',
    );
    notifyListeners();
  }

  // ================= SEARCH HISTORY =================
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _searchHistory = prefs.getStringList('search_history') ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      // Loại bỏ query nếu đã có
      _searchHistory.removeWhere(
        (item) => item.toLowerCase() == query.toLowerCase(),
      );

      // Thêm vào đầu
      _searchHistory.insert(0, query.trim());

      // Giữ lại tối đa 10 items
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }

      // Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to search history: $e');
    }
  }

  Future<void> removeFromHistory(String query) async {
    try {
      _searchHistory.removeWhere((item) => item == query);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from search history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      _searchHistory.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  // ================= SEARCH =================
  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      final lowerQuery = query.toLowerCase();

      debugPrint('🔍 SEARCH DEBUG: query="$query", lowerQuery="$lowerQuery"');
      debugPrint('🔍 Total songs available: ${_allSongs.length}');
      debugPrint(
        '🔍 Song list: ${_allSongs.map((s) => "${s.title} - ${s.artistName}").join(", ")}',
      );

      // If local songs list isn't populated yet, fallback to usecase (remote/search API)
      if (_allSongs.isEmpty) {
        debugPrint('🔍 Local song cache empty — using SearchSongs usecase');
        final results = await searchSongs(query);
        _searchedSongs = results;
        debugPrint(
          '🔍 Found ${_searchedSongs.length} songs from usecase for "$query"',
        );

        // mark loading false and notify
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Search Songs
      _searchedSongs = _allSongs
          .where(
            (song) =>
                song.title.toLowerCase().contains(lowerQuery) ||
                song.artistName.toLowerCase().contains(lowerQuery),
          )
          .toList();

      debugPrint('🔍 Found ${_searchedSongs.length} songs matching "$query"');

      // Search Artists
      _searchedArtists = _allArtists
          .where((artist) => artist.name.toLowerCase().contains(lowerQuery))
          .toList();

      // Search Albums
      _searchedAlbums = _allAlbums
          .where((album) => album.title.toLowerCase().contains(lowerQuery))
          .toList();

      // Search Playlists
      _searchedPlaylists = _allPlaylists
          .where((playlist) => playlist.name.toLowerCase().contains(lowerQuery))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= TAB SELECTION =================
  void selectTab(SearchTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // ================= CLEAR SEARCH =================
  void clearSearch() {
    _searchQuery = '';
    _selectedTab = SearchTab.all;
    _searchedSongs = [];
    _searchedArtists = [];
    _searchedAlbums = [];
    _searchedPlaylists = [];
    notifyListeners();
  }

  // ================= GET CURRENT RESULTS =================
  List<dynamic> getCurrentResults() {
    if (_selectedTab == SearchTab.all) {
      return [
        ..._searchedArtists,
        ..._searchedAlbums,
        ..._searchedPlaylists,
        ..._searchedSongs,
      ];
    } else if (_selectedTab == SearchTab.songs) {
      return _searchedSongs;
    } else if (_selectedTab == SearchTab.artists) {
      return _searchedArtists;
    } else if (_selectedTab == SearchTab.albums) {
      return _searchedAlbums;
    } else if (_selectedTab == SearchTab.playlists) {
      return _searchedPlaylists;
    }

    return [];
  }

  // ================= SEARCH AND SAVE TO HISTORY =================
  Future<void> searchAndSave(String query) async {
    if (query.trim().isEmpty) return;
    await addToHistory(query);
    await search(query);
  }
}
