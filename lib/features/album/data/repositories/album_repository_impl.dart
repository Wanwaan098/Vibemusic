import 'package:music_app/features/album/data/datasources/album_remote_data_source.dart';
import 'package:music_app/features/album/data/models/album_model.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumRemoteDataSource remoteDataSource;

  AlbumRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Album>> getAlbums() async {
    return await remoteDataSource.getAlbums();
  }

  @override
  Future<Album?> getAlbumById(String id) async {
    return await remoteDataSource.getAlbumById(id);
  }

  @override
  Future<List<Album>> getAlbumsByArtist(String artistId) async {
    return await remoteDataSource.getAlbumsByArtist(artistId);
  }

  @override
  Future<void> addAlbum(Album album) async {
    final albumModel = AlbumModel(
      id: album.id,
      title: album.title,
      artistId: album.artistId,
      coverUrl: album.coverUrl,
      releaseYear: album.releaseYear,
      createdAt: album.createdAt,
    );
    await remoteDataSource.addAlbum(albumModel);
  }

  @override
  Future<void> updateAlbum(Album album) async {
    final albumModel = AlbumModel(
      id: album.id,
      title: album.title,
      artistId: album.artistId,
      coverUrl: album.coverUrl,
      releaseYear: album.releaseYear,
      createdAt: album.createdAt,
    );
    await remoteDataSource.updateAlbum(albumModel);
  }

  @override
  Future<void> deleteAlbum(String id) async {
    await remoteDataSource.deleteAlbum(id);
  }
}
