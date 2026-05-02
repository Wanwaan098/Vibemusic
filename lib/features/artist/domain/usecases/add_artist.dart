
import '../entities/artist.dart';
import '../repositories/artist_repository.dart';

class AddArtist {
  final ArtistRepository repository;

  AddArtist(this.repository);

  Future<void> call(Artist artist) {
    return repository.addArtist(artist);
  }
}
