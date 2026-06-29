import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/system_playlist_model.dart';

class SystemPlaylistRemoteDataSource {
  final FirebaseFirestore firestore;

  SystemPlaylistRemoteDataSource(this.firestore);

  Future<List<SystemPlaylistModel>> getSystemPlaylists() async {
    final snapshot = await firestore
        .collection('playlists')
        .where('is_system', isEqualTo: true)
        .get();

    final playlists = snapshot.docs
        .map(
          (doc) => SystemPlaylistModel.fromJson({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();

    // Sort bằng Dart thay vì Firestore để tránh lỗi thiếu index
    playlists.sort(
      (a, b) => a.priority.compareTo(b.priority),
    );

    return playlists;
  }

  Future<void> createSystemPlaylist({
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    final playlistId = const Uuid().v4();

    await firestore.collection('playlists').doc(playlistId).set({
      'id': playlistId,
      'name': name,
      'description': description,
      'is_system': true,
      'owner_id': 'admin',
      'thumbnail': thumbnail,
      'priority': priority,
      'song_count': songIds.length,
      'song_ids': songIds,
      'created_at': Timestamp.now(),
    });
  }

  Future<void> updateSystemPlaylist({
    required String id,
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    await firestore.collection('playlists').doc(id).update({
      'name': name,
      'description': description,
      'thumbnail': thumbnail,
      'priority': priority,
      'song_count': songIds.length,
      'song_ids': songIds,
    });
  }

  Future<void> deleteSystemPlaylist(String id) async {
    await firestore.collection('playlists').doc(id).delete();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final doc = await firestore
        .collection('playlists')
        .doc(playlistId)
        .get();

    if (doc.exists) {
      final songIds = List<String>.from(doc.data()?['song_ids'] ?? []);

      if (!songIds.contains(songId)) {
        songIds.add(songId);

        await firestore.collection('playlists').doc(playlistId).update({
          'song_ids': songIds,
          'song_count': songIds.length,
        });
      }
    }
  }

  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    final doc = await firestore
        .collection('playlists')
        .doc(playlistId)
        .get();

    if (doc.exists) {
      final songIds = List<String>.from(doc.data()?['song_ids'] ?? []);

      songIds.remove(songId);

      await firestore.collection('playlists').doc(playlistId).update({
        'song_ids': songIds,
        'song_count': songIds.length,
      });
    }
  }
}