import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';
import 'package:music_app/features/playlist/domain/repositories/system_playlist_repository.dart';

class GetSystemPlaylists {
  final SystemPlaylistRepository repository;

  GetSystemPlaylists(this.repository);

  Future<List<SystemPlaylist>> call() async {
    return await repository.getSystemPlaylists();
  }
}

class CreateSystemPlaylist {
  final SystemPlaylistRepository repository;

  CreateSystemPlaylist(this.repository);

  Future<void> call({
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    await repository.createSystemPlaylist(
      name: name,
      description: description,
      thumbnail: thumbnail,
      priority: priority,
      songIds: songIds,
    );
  }
}

class UpdateSystemPlaylist {
  final SystemPlaylistRepository repository;

  UpdateSystemPlaylist(this.repository);

  Future<void> call({
    required String id,
    required String name,
    required String description,
    required String thumbnail,
    required int priority,
    required List<String> songIds,
  }) async {
    await repository.updateSystemPlaylist(
      id: id,
      name: name,
      description: description,
      thumbnail: thumbnail,
      priority: priority,
      songIds: songIds,
    );
  }
}

class DeleteSystemPlaylist {
  final SystemPlaylistRepository repository;

  DeleteSystemPlaylist(this.repository);

  Future<void> call(String id) async {
    await repository.deleteSystemPlaylist(id);
  }
}

class AddSongToSystemPlaylist {
  final SystemPlaylistRepository repository;

  AddSongToSystemPlaylist(this.repository);

  Future<void> call(String playlistId, String songId) async {
    await repository.addSongToPlaylist(playlistId, songId);
  }
}

class RemoveSongFromSystemPlaylist {
  final SystemPlaylistRepository repository;

  RemoveSongFromSystemPlaylist(this.repository);

  Future<void> call(String playlistId, String songId) async {
    await repository.removeSongFromPlaylist(playlistId, songId);
  }
}
