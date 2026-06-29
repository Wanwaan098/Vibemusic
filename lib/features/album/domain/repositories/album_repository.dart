import '../entities/album.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAlbums();
  Future<Album?> getAlbumById(String id);
  Future<List<Album>> getAlbumsByArtist(String artistId);
  Future<void> addAlbum(Album album);
  Future<void> updateAlbum(Album album);
  Future<void> deleteAlbum(String id);
}
