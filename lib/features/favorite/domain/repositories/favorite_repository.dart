import 'package:music_app/features/favorite/domain/entities/user_favorite.dart';

abstract class FavoriteRepository {
  Future<UserFavorite> getFavoritesByUser(String userId);
  Future<void> addToFavorites(String userId, String songId);
  Future<void> removeFromFavorites(String userId, String songId);
  Future<bool> isFavorite(String userId, String songId);
}
