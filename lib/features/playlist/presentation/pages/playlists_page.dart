import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:music_app/features/playlist/presentation/pages/playlist_detail_page.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  bool _isSidebarExpanded = false;

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
    final playlistProvider = context.watch<PlaylistProvider>();
    final songProvider = context.watch<SongProvider>();

    return Scaffold(
      body: Row(
        children: [
          UserSidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            onLogout: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: const Text("Playlists"),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _showCreatePlaylistDialog(context);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: playlistProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : playlistProvider.playlists.isEmpty
                      ? const Center(child: Text("Không có playlist nào"))
                      : ListView.builder(
                          itemCount: playlistProvider.playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = playlistProvider.playlists[index];

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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.music_note,
                                          color: Colors.grey,
                                        ),
                                      ),
                                title: Text(playlist.name),
                                subtitle: Text(
                                  "${playlist.songIds.length} bài hát",
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaylistDetailPage(
                                        playlistId: playlist.id,
                                      ),
                                    ),
                                  );
                                },
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () async {
                                        await playlistProvider
                                            .deletePlaylistLocal(playlist.id);
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
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
