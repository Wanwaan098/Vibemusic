import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';

class SongRemoteDataSource {
  final FirebaseFirestore firestore;

  SongRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _songs =>
      firestore.collection('songs');

  // ✅ GET ALL SONGS (có sort)
  Future<List<SongModel>> getSongs() async {
    final snapshot = await _songs
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SongModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  // ✅ GET DETAIL (safe null)
  Future<SongModel> getSong(String id) async {
    final doc = await _songs.doc(id).get();

    if (!doc.exists) {
      throw Exception('Song not found');
    }

    return SongModel.fromJson(doc.id, doc.data()!);
  }

  // ✅ ADD
  Future<void> addSong(SongModel song) async {
    await _songs.add(song.toJson());
  }

  // ✅ UPDATE
  Future<void> updateSong(SongModel song) async {
    await _songs.doc(song.id).update(song.toJson());
  }

  // ✅ DELETE
  Future<void> deleteSong(String id) async {
    await _songs.doc(id).delete();
  }

  // ✅ INCREASE PLAY COUNT (atomic)
  Future<void> increasePlayCount(String id) async {
    await _songs.doc(id).update({
      "play_count": FieldValue.increment(1),
    });
  }

  // 🔥 SEARCH CHUẨN (prefix search)
  Future<List<SongModel>> searchSongs(String query) async {
    final q = query.toLowerCase();

    final snapshot = await _songs
        .orderBy('title_lowercase')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .get();

    return snapshot.docs
        .map((e) => SongModel.fromJson(e.id, e.data()))
        .toList();
  }
}