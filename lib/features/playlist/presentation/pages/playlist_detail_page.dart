import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
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
    final playlistProvider = context.watch<PlaylistProvider>();
    final songProvider = context.watch<SongProvider>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Find the playlist safely
    final playlistIndex = playlistProvider.playlists.indexWhere(
      (p) => p.id == widget.playlistId,
    );

    if (playlistIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text("Playlist")),
        body: const Center(child: Text("Playlist không được tìm thấy")),
      );
    }

    final playlist = playlistProvider.playlists[playlistIndex];

    final playlistSongs = playlist.songIds
        .map((id) {
          try {
            return songProvider.songs.firstWhere((s) => s.id == id);
          } catch (e) {
            return null;
          }
        })
        .whereType<Song>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: playlistSongs.isEmpty
          ? const Center(child: Text("Playlist trống"))
          : ListView.builder(
              itemCount: playlistSongs.length,
              itemBuilder: (context, index) {
                final song = playlistSongs[index];

                return ListTile(
                  leading: Image.network(song.coverUrl, width: 50, height: 50),
                  title: Text(song.title),
                  subtitle: Text(song.artistName),
                  onTap: () {
                    songProvider.playSongFromList(
                      song,
                      playlist: playlistSongs,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SongDetailPage(songId: song.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
