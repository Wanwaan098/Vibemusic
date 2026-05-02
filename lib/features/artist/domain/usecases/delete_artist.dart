import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class DeleteArtist {
  final ArtistRepository repository;

  DeleteArtist(this.repository);

  Future<void> call(String id) {
    return repository.deleteArtist(id);
  }
}