import 'package:music_app/features/playlist/domain/entities/playlist.dart';
import 'package:music_app/features/playlist/domain/repositories/playlist_repository.dart';

class GetPlaylistsByUser {
  final PlaylistRepository repository;
  GetPlaylistsByUser(this.repository);

  Future<List<Playlist>> call(String userId) {
    return repository.getPlaylistsByUser(userId);
  }
}

class GetPlaylist {
  final PlaylistRepository repository;
  GetPlaylist(this.repository);

  Future<Playlist> call(String playlistId) {
    return repository.getPlaylist(playlistId);
  }
}

class CreatePlaylist {
  final PlaylistRepository repository;
  CreatePlaylist(this.repository);

  Future<void> call(Playlist playlist) {
    return repository.createPlaylist(playlist);
  }
}

class UpdatePlaylist {
  final PlaylistRepository repository;
  UpdatePlaylist(this.repository);

  Future<void> call(Playlist playlist) {
    return repository.updatePlaylist(playlist);
  }
}

class DeletePlaylist {
  final PlaylistRepository repository;
  DeletePlaylist(this.repository);

  Future<void> call(String playlistId) {
    return repository.deletePlaylist(playlistId);
  }
}

class AddSongToPlaylist {
  final PlaylistRepository repository;
  AddSongToPlaylist(this.repository);

  Future<void> call(String playlistId, String songId) {
    return repository.addSongToPlaylist(playlistId, songId);
  }
}

class RemoveSongFromPlaylist {
  final PlaylistRepository repository;
  RemoveSongFromPlaylist(this.repository);

  Future<void> call(String playlistId, String songId) {
    return repository.removeSongFromPlaylist(playlistId, songId);
  }
}
