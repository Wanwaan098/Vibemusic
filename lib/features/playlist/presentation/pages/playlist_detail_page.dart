import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final playlistProvider = context.read<PlaylistProvider>();
      final songProvider = context.read<SongProvider>();
      final authProvider = context.read<AuthProvider>();

      // Load playlists if empty
      if (playlistProvider.playlists.isEmpty) {
        final userId = authProvider.user?.uid ?? '';
        await playlistProvider.loadPlaylists(userId);
      }

      // Load all songs if empty
      if (songProvider.songs.isEmpty) {
        await songProvider.loadSongs();
      }

      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: _buildPlaylistTitle()),
      body: Column(
        children: [
          // ================= PLAYLIST SONGS LIST =================
          Expanded(child: _buildPlaylistSongsList()),
        ],
      ),
      bottomNavigationBar: Consumer<SongProvider>(
        builder: (context, provider, _) {
          if (provider.currentSong == null || !provider.showMiniPlayer) {
            return const SizedBox.shrink();
          }
          return const MiniPlayer();
        },
      ),
    );
  }

  // ✅ Widget riêng để lấy playlist title - chỉ rebuild khi playlist name thay đổi
  Widget _buildPlaylistTitle() {
    return Selector<PlaylistProvider, String?>(
      selector: (_, provider) {
        final playlistIndex = provider.playlists.indexWhere(
          (p) => p.id == widget.playlistId,
        );
        return playlistIndex != -1
            ? provider.playlists[playlistIndex].name
            : null;
      },
      builder: (context, playlistName, _) {
        return Text(playlistName ?? "Playlist");
      },
    );
  }

  // ✅ Widget riêng cho PlaylistSongsList - tối ưu rebuild
  Widget _buildPlaylistSongsList() {
    return Selector<PlaylistProvider, (int, List<String>)>(
      selector: (_, provider) {
        final playlistIndex = provider.playlists.indexWhere(
          (p) => p.id == widget.playlistId,
        );
        if (playlistIndex == -1) {
          return (-1, []);
        }
        return (playlistIndex, provider.playlists[playlistIndex].songIds);
      },
      builder: (context, data, _) {
        final playlistIndex = data.$1;
        final songIds = data.$2;

        if (playlistIndex == -1) {
          return const Center(child: Text("Playlist không được tìm thấy"));
        }

        return _buildPlaylistSongsListView(songIds);
      },
    );
  }

  // ✅ ListView riêng - chỉ rebuild khi songs thay đổi
  Widget _buildPlaylistSongsListView(List<String> songIds) {
    return Selector<SongProvider, List<Song>>(
      selector: (_, provider) {
        return songIds
            .map((id) {
              try {
                return provider.songs.firstWhere((s) => s.id == id);
              } catch (e) {
                return null;
              }
            })
            .whereType<Song>()
            .toList();
      },
      builder: (context, playlistSongs, _) {
        if (playlistSongs.isEmpty) {
          return const Center(child: Text("Playlist trống"));
        }

        return ListView.builder(
          itemCount: playlistSongs.length,
          itemBuilder: (context, index) {
            final song = playlistSongs[index];

            return ListTile(
              leading: Image.network(song.coverUrl, width: 50, height: 50),
              title: Text(song.title),
              subtitle: Text(song.artistName),
              onTap: () {
                final songProvider = context.read<SongProvider>();
                songProvider.playSongFromList(song, playlist: playlistSongs);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailPage(songId: song.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
