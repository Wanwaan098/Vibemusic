import '../entities/album.dart';
import '../repositories/album_repository.dart';

class GetAlbumsByArtist {
  final AlbumRepository repository;

  GetAlbumsByArtist(this.repository);

  Future<List<Album>> call(String artistId) async {
    return await repository.getAlbumsByArtist(artistId);
  }
}
