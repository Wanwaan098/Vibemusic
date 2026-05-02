import 'package:flutter/material.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/usecases/add_artist.dart';
import 'package:music_app/features/artist/domain/usecases/delete_artist.dart';
import 'package:music_app/features/artist/domain/usecases/get_artists.dart';
import 'package:music_app/features/artist/domain/usecases/update_artist.dart';

class ArtistManagerProvider extends ChangeNotifier {
  final GetArtists getArtistsUseCase;
  final AddArtist addArtistUseCase;
  final UpdateArtist updateArtistUseCase;
  final DeleteArtist deleteArtistUseCase;

  ArtistManagerProvider({
    required this.getArtistsUseCase,
    required this.addArtistUseCase,
    required this.updateArtistUseCase,
    required this.deleteArtistUseCase,
  });

  List<Artist> artists = [];
  bool isLoading = false;

  // ✅ FIX: thêm error
  String? error;

  // ================= GET LIST =================
  Future<void> fetchArtists() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      artists = await getArtistsUseCase();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= ADD =================
  Future<void> addArtist(Artist artist) async {
    try {
      isLoading = true;
      notifyListeners();

      await addArtistUseCase(artist);
      await fetchArtists();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ================= UPDATE =================
  Future<void> updateArtist(Artist artist) async {
    try {
      isLoading = true;
      notifyListeners();

      await updateArtistUseCase(artist);
      await fetchArtists();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ================= DELETE =================
  Future<void> deleteArtistById(String id) async {
    try {
      await deleteArtistUseCase(id);

      // update UI ngay (không cần fetch lại)
      artists.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}