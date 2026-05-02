import '../entities/song.dart';

abstract class SongRepository {
  Future<List<Song>> getSongs();
  Future<Song> getSong(String id);
  Future<void> addSong(Song song);
  Future<void> updateSong(Song song);
  Future<void> deleteSong(String id);
  Future<void> increasePlayCount(String id);
  Future<List<Song>> searchSongs(String query);
}