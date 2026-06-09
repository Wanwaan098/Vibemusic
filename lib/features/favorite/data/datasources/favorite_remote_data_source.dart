import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_app/features/favorite/domain/entities/user_favorite.dart';

abstract class FavoriteRemoteDataSource {
  Future<UserFavorite> getFavoritesByUser(String userId);
  Future<void> addToFavorites(String userId, String songId);
  Future<void> removeFromFavorites(String userId, String songId);
  Future<bool> isFavorite(String userId, String songId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final FirebaseFirestore _firestore;

  FavoriteRemoteDataSourceImpl(this._firestore);

  @override
  Future<UserFavorite> getFavoritesByUser(String userId) async {
    final doc = await _firestore.collection('favorites').doc(userId).get();

    if (!doc.exists) {
      return UserFavorite(
        id: userId,
        userId: userId,
        songIds: [],
        updatedAt: DateTime.now(),
      );
    }

    final data = doc.data()!;
    return UserFavorite(
      id: doc.id,
      userId: userId,
      songIds: List<String>.from(data['songIds'] ?? []),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Future<void> addToFavorites(String userId, String songId) async {
    await _firestore.collection('favorites').doc(userId).set({
      'songIds': FieldValue.arrayUnion([songId]),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> removeFromFavorites(String userId, String songId) async {
    await _firestore.collection('favorites').doc(userId).update({
      'songIds': FieldValue.arrayRemove([songId]),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<bool> isFavorite(String userId, String songId) async {
    final fav = await getFavoritesByUser(userId);
    return fav.songIds.contains(songId);
  }
}
