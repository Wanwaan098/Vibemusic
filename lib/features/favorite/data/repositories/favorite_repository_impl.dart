import 'package:music_app/features/favorite/data/datasources/favorite_remote_data_source.dart';
import 'package:music_app/features/favorite/domain/entities/user_favorite.dart';
import 'package:music_app/features/favorite/domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;

  FavoriteRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserFavorite> getFavoritesByUser(String userId) {
    return _remoteDataSource.getFavoritesByUser(userId);
  }

  @override
  Future<void> addToFavorites(String userId, String songId) {
    return _remoteDataSource.addToFavorites(userId, songId);
  }

  @override
  Future<void> removeFromFavorites(String userId, String songId) {
    return _remoteDataSource.removeFromFavorites(userId, songId);
  }

  @override
  Future<bool> isFavorite(String userId, String songId) {
    return _remoteDataSource.isFavorite(userId, songId);
  }
}
