import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:music_app/core/widgets/top_navbar.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/features/playlist/presentation/pages/playlist_detail_page.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/playlist/domain/entities/playlist.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      final songProvider = context.read<SongProvider>();
      final userId = authProvider.user?.uid ?? '';

      // Load playlists
      await context.read<PlaylistProvider>().loadPlaylists(userId);

      // Load songs if not already loaded
      if (songProvider.songs.isEmpty) {
        await songProvider.loadSongs();
      }
    });
  }

  // Helper method to get thumbnail URL for a playlist.
  // Prefer explicit playlist.thumbnailUrl; otherwise use the most recently added song's cover.
  String? _getPlaylistThumbnail(Playlist playlist, List<Song> songs) {
    if (playlist.thumbnailUrl != null && playlist.thumbnailUrl!.isNotEmpty) {
      return playlist.thumbnailUrl;
    }

    if (playlist.songIds.isEmpty || songs.isEmpty) return null;

    final lastSongId = playlist.songIds.last;
    try {
      final song = songs.firstWhere((s) => s.id == lastSongId);
      return song.coverUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: TopNavbar(
        onMenuPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        onSearchPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tìm kiếm - Tính năng sắp có")),
          );
        },
      ),
      drawer: UserSidebar(
        onLogout: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePlaylistDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: Column(
        children: [
          // ================= PLAYLISTS LIST =================
          Expanded(child: _buildPlaylistsList()),
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

  // ✅ Widget riêng cho PlaylistsList - tối ưu rebuild
  Widget _buildPlaylistsList() {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.playlists.isEmpty) {
          return const Center(child: Text("Không có playlist nào"));
        }

        return _buildPlaylistsListView();
      },
    );
  }

  // ✅ ListView riêng - chỉ rebuild khi playlists thay đổi
  Widget _buildPlaylistsListView() {
    return Selector<PlaylistProvider, List>(
      selector: (_, provider) => provider.playlists,
      builder: (context, playlists, _) {
        final songProvider = context.watch<SongProvider>();

        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index] as Playlist;

            // Get thumbnail from playlist.thumbnailUrl or latest song
            final thumbnailUrl = _getPlaylistThumbnail(
              playlist,
              songProvider.songs.cast<Song>(),
            );

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          thumbnailUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.music_note, color: Colors.grey),
                      ),
                title: Text(playlist.name),
                subtitle: Text("${playlist.songIds.length} bài hát"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PlaylistDetailPage(playlistId: playlist.id),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    final provider = context.read<PlaylistProvider>();
                    if (value == 'delete') {
                      await provider.deletePlaylistLocal(playlist.id);
                    } else if (value == 'rename') {
                      _showRenamePlaylistDialog(context, playlist);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Playlist name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final authProvider = context.read<AuthProvider>();
                final userId = authProvider.user?.uid ?? '';
                await context.read<PlaylistProvider>().createNewPlaylist(
                  userId,
                  controller.text,
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showRenamePlaylistDialog(BuildContext context, dynamic playlist) {
    final controller = TextEditingController(text: playlist.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Playlist name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<PlaylistProvider>().updatePlaylistNameLocal(
                  playlist.id,
                  controller.text,
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
