import '../../domain/entities/artist.dart';
import '../../domain/repositories/artist_repository.dart';
import '../datasources/artist_remote_data_source.dart';
import '../models/artist_model.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistRemoteDataSource remote;

  ArtistRepositoryImpl(this.remote);

  @override
  Future<List<Artist>> getArtists() async {
    return await remote.getArtists();
  }

  @override
  Future<Artist> getArtist(String id) async {
    return await remote.getArtist(id);
  }

  @override
  Future<void> addArtist(Artist artist) async {
    final model = ArtistModel(
      id: '',
      name: artist.name,
      biography: artist.biography,
      avatarUrl: artist.avatarUrl,
      createdAt: DateTime.now(),
    );

    await remote.addArtist(model);
  }

  @override
  Future<void> updateArtist(Artist artist) async {
    final model = ArtistModel(
      id: artist.id,
      name: artist.name,
      biography: artist.biography,
      avatarUrl: artist.avatarUrl,
      createdAt: artist.createdAt,
    );

    await remote.updateArtist(model);
  }

  @override
  Future<void> deleteArtist(String id) async {
    await remote.deleteArtist(id);
  }
}