import '../entities/artist.dart';
import '../repositories/artist_repository.dart';

class GetArtists {
  final ArtistRepository repository;

  GetArtists(this.repository);

  Future<List<Artist>> call() {
    return repository.getArtists();
  }
}