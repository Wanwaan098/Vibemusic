import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artist_model.dart';

class ArtistRemoteDataSource {
  final FirebaseFirestore firestore;

  ArtistRemoteDataSource(this.firestore);

  final collection = "artists";

  Future<List<ArtistModel>> getArtists() async {
    final snapshot = await firestore.collection(collection).get();

    return snapshot.docs
        .map((doc) => ArtistModel.fromFirestore(doc))
        .toList();
  }

  Future<ArtistModel> getArtist(String id) async {
    final doc = await firestore.collection(collection).doc(id).get();

    return ArtistModel.fromFirestore(doc);
  }

  Future<void> addArtist(ArtistModel artist) async {
    await firestore.collection(collection).add(artist.toMap());
  }

  Future<void> updateArtist(ArtistModel artist) async {
    await firestore
        .collection(collection)
        .doc(artist.id)
        .update(artist.toMap());
  }

  Future<void> deleteArtist(String id) async {
    await firestore.collection(collection).doc(id).delete();
  }
}