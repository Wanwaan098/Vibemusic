import '../entities/album.dart';
import '../repositories/album_repository.dart';

class UpdateAlbum {
  final AlbumRepository repository;

  UpdateAlbum(this.repository);

  Future<void> call(Album album) async {
    return await repository.updateAlbum(album);
  }
}
