import '../repositories/album_repository.dart';

class DeleteAlbum {
  final AlbumRepository repository;

  DeleteAlbum(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteAlbum(id);
  }
}
