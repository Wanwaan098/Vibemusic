import 'package:music_app/features/artist/domain/entities/artist.dart';

abstract class ArtistRepository {
  Future<List<Artist>> getArtists();
  Future<Artist> getArtist(String id);
  Future<void> addArtist(Artist artist);
  Future<void> updateArtist(Artist artist);
  Future<void> deleteArtist(String id);
}