import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_app/features/playlist/domain/entities/playlist.dart';

abstract class PlaylistRemoteDataSource {
  Future<List<Playlist>> getPlaylistsByUser(String userId);
  Future<Playlist> getPlaylist(String playlistId);
  Future<void> createPlaylist(Playlist playlist);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final FirebaseFirestore _firestore;

  PlaylistRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<Playlist>> getPlaylistsByUser(String userId) async {
    final snapshot = await _firestore
        .collection('playlists')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Playlist(
        id: doc.id,
        userId: data['userId'],
        name: data['name'],
        thumbnailUrl: data['thumbnailUrl'],
        songIds: List<String>.from(data['songIds'] ?? []),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<Playlist> getPlaylist(String playlistId) async {
    final doc = await _firestore.collection('playlists').doc(playlistId).get();

    if (!doc.exists) throw Exception('Playlist not found');

    final data = doc.data()!;
    return Playlist(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      thumbnailUrl: data['thumbnailUrl'],
      songIds: List<String>.from(data['songIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    await _firestore.collection('playlists').add({
      'userId': playlist.userId,
      'name': playlist.name,
      'thumbnailUrl': playlist.thumbnailUrl,
      'songIds': playlist.songIds,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    await _firestore.collection('playlists').doc(playlist.id).update({
      'name': playlist.name,
      'thumbnailUrl': playlist.thumbnailUrl,
    });
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    await _firestore.collection('playlists').doc(playlistId).delete();
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _firestore.collection('playlists').doc(playlistId).update({
      'songIds': FieldValue.arrayUnion([songId]),
    });
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _firestore.collection('playlists').doc(playlistId).update({
      'songIds': FieldValue.arrayRemove([songId]),
    });
  }
}
