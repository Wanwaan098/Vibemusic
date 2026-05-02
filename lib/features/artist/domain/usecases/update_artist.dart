import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class UpdateArtist {
  final ArtistRepository repository;

  UpdateArtist(this.repository);

  Future<void> call(Artist artist) {
    return repository.updateArtist(artist);
  }
}
