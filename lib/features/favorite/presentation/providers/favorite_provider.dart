import 'package:flutter/material.dart';
import 'package:music_app/features/favorite/domain/usecases/favorite_usecases.dart';

class FavoriteProvider extends ChangeNotifier {
  final GetFavoritesByUser getFavoritesByUser;
  final AddToFavorites addToFavorites;
  final RemoveFromFavorites removeFromFavorites;
  final IsFavorite isFavorite;

  FavoriteProvider({
    required this.getFavoritesByUser,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.isFavorite,
  });

  Set<String> favoriteSongIds = {};
  bool isLoading = false;

  Future<void> loadFavorites(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final userFav = await getFavoritesByUser(userId);
      favoriteSongIds = Set<String>.from(userFav.songIds);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFavorite(String userId, String songId) async {
    try {
      if (favoriteSongIds.contains(songId)) {
        favoriteSongIds.remove(songId);
        notifyListeners();
        await removeFromFavorites(userId, songId);
      } else {
        favoriteSongIds.add(songId);
        notifyListeners();
        await addToFavorites(userId, songId);
      }
    } catch (e) {
      rethrow;
    }
  }

  bool isFavoriteSong(String songId) {
    return favoriteSongIds.contains(songId);
  }
}
