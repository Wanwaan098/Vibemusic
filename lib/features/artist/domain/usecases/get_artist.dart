import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class GetArtist {
  final ArtistRepository repository;

  GetArtist(this.repository);

  Future<Artist> call(String id) {
    return repository.getArtist(id);
  }
}