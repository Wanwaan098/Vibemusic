import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/playlist/presentation/providers/system_playlist_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/core/widgets/top_navbar.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/features/song/domain/entities/song.dart';

class SystemPlaylistDetailPage extends StatefulWidget {
  final String playlistId;

  const SystemPlaylistDetailPage({super.key, required this.playlistId});

  @override
  State<SystemPlaylistDetailPage> createState() =>
      _SystemPlaylistDetailPageState();
}

class _SystemPlaylistDetailPageState extends State<SystemPlaylistDetailPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      final systemPlaylistProvider = context.read<SystemPlaylistProvider>();
      final songProvider = context.read<SongProvider>();

      // Load system playlists
      await systemPlaylistProvider.loadPlaylists();

      // Load songs
      if (songProvider.songs.isEmpty) {
        await songProvider.loadSongs();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Lỗi: ${snapshot.error}')));
        }

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppColors.background,
          appBar: TopNavbar(
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
            onSearchPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tìm kiếm - Tính năng sắp có")),
              );
            },
          ),
          drawer: UserSidebar(
            onLogout: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          body: Column(
            children: [
              Expanded(child: _buildContent()),
              // Mini player at bottom
              Consumer<SongProvider>(
                builder: (context, provider, _) {
                  if (provider.currentSong == null ||
                      !provider.showMiniPlayer) {
                    return const SizedBox();
                  }
                  return const MiniPlayer();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Selector<SystemPlaylistProvider, Map<String, dynamic>?>(
      selector: (_, provider) {
        try {
          final playlistIndex = provider.playlists.indexWhere(
            (p) => p.id == widget.playlistId,
          );
          if (playlistIndex == -1) {
            return null;
          }
          final playlist = provider.playlists[playlistIndex];
          return {
            'id': playlist.id,
            'name': playlist.name,
            'thumbnail': playlist.thumbnail,
            'songCount': playlist.songCount,
            'description': playlist.description,
            'songIds': playlist.songIds,
          };
        } catch (e) {
          debugPrint('Error in selector: $e');
          return null;
        }
      },
      builder: (context, playlistInfo, _) {
        if (playlistInfo == null) {
          return const Center(child: Text("Playlist không được tìm thấy"));
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // ============= PLAYLIST HEADER =============
            _buildHeader(playlistInfo),

            // ============= SONGS LIST =============
            _buildSongsList(playlistInfo['songIds'] as List<String>),
          ],
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> playlistInfo) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              playlistInfo['thumbnail'] ?? '',
              width: double.maxFinite,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.maxFinite,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.grey,
                    size: 80,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Playlist name
          Text(
            playlistInfo['name'] ?? 'Playlist',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          if ((playlistInfo['description'] as String?)?.isNotEmpty ?? false)
            Text(
              playlistInfo['description'] as String,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 12),

          // Song count
          Text(
            "${playlistInfo['songCount'] ?? 0} bài hát",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSongsList(List<String> songIds) {
    if (songIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Chưa có bài hát nào trong playlist này",
            style: TextStyle(color: AppColors.textPrimary.withOpacity(0.5)),
          ),
        ),
      );
    }

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
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                "Chưa có bài hát nào trong playlist này",
                style: TextStyle(color: AppColors.textPrimary.withOpacity(0.5)),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: playlistSongs.length,
          itemBuilder: (context, index) {
            final song = playlistSongs[index];

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.coverUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.lightPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.grey,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
              title: Text(
                song.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                song.artistName,
                style: TextStyle(color: AppColors.textPrimary.withOpacity(0.6)),
              ),
              trailing: Text(
                "${index + 1}",
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                try {
                  final songProvider = context.read<SongProvider>();
                  songProvider.playSongFromList(song, playlist: playlistSongs);
                  songProvider.showMini();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongDetailPage(songId: song.id),
                    ),
                  );
                } catch (e) {
                  debugPrint('Error playing song: $e');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              },
            );
          },
        );
      },
    );
  }
}
