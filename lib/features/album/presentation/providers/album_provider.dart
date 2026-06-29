import 'package:flutter/material.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/usecases/get_albums.dart';
import 'package:music_app/features/album/domain/usecases/get_albums_by_artist.dart';
import 'package:music_app/features/album/domain/usecases/add_album.dart';
import 'package:music_app/features/album/domain/usecases/update_album.dart';
import 'package:music_app/features/album/domain/usecases/delete_album.dart';

class AlbumProvider extends ChangeNotifier {
  final GetAlbums getAlbums;
  final GetAlbumsByArtist getAlbumsByArtist;
  final AddAlbum addAlbum;
  final UpdateAlbum updateAlbum;
  final DeleteAlbum deleteAlbum;

  List<Album> _albums = [];
  List<Album> _artistAlbums = [];
  bool _isLoading = false;
  String? _error;

  AlbumProvider({
    required this.getAlbums,
    required this.getAlbumsByArtist,
    required this.addAlbum,
    required this.updateAlbum,
    required this.deleteAlbum,
  });

  List<Album> get albums => _albums;
  List<Album> get artistAlbums => _artistAlbums;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAlbums() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _albums = await getAlbums();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlbumsByArtist(String artistId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _artistAlbums = await getAlbumsByArtist(artistId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAlbum({
    required String title,
    required String artistId,
    required String coverUrl,
    required int releaseYear,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final album = Album(
        id: '',
        title: title,
        artistId: artistId,
        coverUrl: coverUrl,
        releaseYear: releaseYear,
        createdAt: DateTime.now(),
      );
      await addAlbum(album);
      await loadAlbums();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editAlbum({
    required String id,
    required String title,
    required String artistId,
    required String coverUrl,
    required int releaseYear,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final album = Album(
        id: id,
        title: title,
        artistId: artistId,
        coverUrl: coverUrl,
        releaseYear: releaseYear,
        createdAt: DateTime.now(),
      );
      await updateAlbum(album);
      await loadAlbums();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeAlbum(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await deleteAlbum(id);
      await loadAlbums();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
