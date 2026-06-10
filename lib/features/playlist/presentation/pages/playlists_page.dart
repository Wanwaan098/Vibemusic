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

  // Helper method to get thumbnail URL for a playlist
  String? _getPlaylistThumbnail(List<String> songIds, List<dynamic> songs) {
    if (songIds.isEmpty || songs.isEmpty) return null;

    // Get the last song ID in the playlist
    final lastSongId = songIds.last;

    // Find the song with this ID
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

          // ================= MINI PLAYER =================
          Selector<SongProvider, (Song?, bool)>(
            selector: (_, provider) =>
                (provider.currentSong, provider.showMiniPlayer),
            builder: (context, data, _) {
              if (data.$1 == null || !data.$2) {
                return const SizedBox();
              }
              return const MiniPlayer();
            },
          ),
        ],
      ),
    );
  }

  // ✅ Widget riêng cho PlaylistsList - tối ưu rebuild
  Widget _buildPlaylistsList() {
    return Selector<PlaylistProvider, bool>(
      selector: (_, provider) => provider.isLoading,
      builder: (context, isLoading, _) {
        final playlistProvider = context.read<PlaylistProvider>();

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (playlistProvider.playlists.isEmpty) {
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
        final songProvider = context.read<SongProvider>();

        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];

            // Get thumbnail from the latest song in playlist
            final thumbnailUrl = _getPlaylistThumbnail(
              playlist.songIds,
              songProvider.songs,
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
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () async {
                        await context
                            .read<PlaylistProvider>()
                            .deletePlaylistLocal(playlist.id);
                      },
                      child: const Text("Delete"),
                    ),
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
}
