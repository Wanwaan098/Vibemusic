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
    // ✅ SECURITY FIX: Clear old favorites before loading new user's favorites
    // This prevents data leakage when switching accounts
    favoriteSongIds.clear();

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
    // Prepare immutable update so Selectors detect changes
    final previous = Set<String>.from(favoriteSongIds);
    final updated = Set<String>.from(favoriteSongIds);

    final removing = updated.contains(songId);
    if (removing) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }

    favoriteSongIds = updated;
    notifyListeners();

    try {
      if (removing) {
        await removeFromFavorites(userId, songId);
      } else {
        await addToFavorites(userId, songId);
      }
    } catch (e) {
      // revert to previous state on failure
      favoriteSongIds = previous;
      notifyListeners();
      rethrow;
    }
  }

  bool isFavoriteSong(String songId) {
    return favoriteSongIds.contains(songId);
  }
}
