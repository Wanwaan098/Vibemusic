import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/album_model.dart';

class AlbumRemoteDataSource {
  final FirebaseFirestore firestore;

  AlbumRemoteDataSource(this.firestore);

  Future<List<AlbumModel>> getAlbums() async {
    final snapshot = await firestore.collection('albums').get();
    return snapshot.docs
        .map((doc) => AlbumModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<AlbumModel?> getAlbumById(String id) async {
    final doc = await firestore.collection('albums').doc(id).get();
    if (doc.exists) {
      return AlbumModel.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  Future<List<AlbumModel>> getAlbumsByArtist(String artistId) async {
    final snapshot = await firestore
        .collection('albums')
        .where('artist_id', isEqualTo: artistId)
        .get();
    return snapshot.docs
        .map((doc) => AlbumModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> addAlbum(AlbumModel album) async {
    final albumId = const Uuid().v4();
    await firestore.collection('albums').doc(albumId).set({
      'id': albumId,
      'title': album.title,
      'artist_id': album.artistId,
      'cover_url': album.coverUrl,
      'release_year': album.releaseYear,
      'created_at': album.createdAt,
    });
  }

  Future<void> updateAlbum(AlbumModel album) async {
    await firestore.collection('albums').doc(album.id).update({
      'title': album.title,
      'artist_id': album.artistId,
      'cover_url': album.coverUrl,
      'release_year': album.releaseYear,
    });
  }

  Future<void> deleteAlbum(String id) async {
    await firestore.collection('albums').doc(id).delete();
  }
}
