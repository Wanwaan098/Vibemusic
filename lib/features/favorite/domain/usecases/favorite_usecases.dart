import 'package:music_app/features/favorite/domain/entities/user_favorite.dart';
import 'package:music_app/features/favorite/domain/repositories/favorite_repository.dart';

class GetFavoritesByUser {
  final FavoriteRepository repository;
  GetFavoritesByUser(this.repository);

  Future<UserFavorite> call(String userId) {
    return repository.getFavoritesByUser(userId);
  }
}

class AddToFavorites {
  final FavoriteRepository repository;
  AddToFavorites(this.repository);

  Future<void> call(String userId, String songId) {
    return repository.addToFavorites(userId, songId);
  }
}

class RemoveFromFavorites {
  final FavoriteRepository repository;
  RemoveFromFavorites(this.repository);

  Future<void> call(String userId, String songId) {
    return repository.removeFromFavorites(userId, songId);
  }
}

class IsFavorite {
  final FavoriteRepository repository;
  IsFavorite(this.repository);

  Future<bool> call(String userId, String songId) {
    return repository.isFavorite(userId, songId);
  }
}
