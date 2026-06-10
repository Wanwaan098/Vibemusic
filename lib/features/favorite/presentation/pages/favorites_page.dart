import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/favorite/presentation/providers/favorite_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:music_app/core/widgets/top_navbar.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Load favorites for current user
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.uid ?? '';
      context.read<FavoriteProvider>().loadFavorites(userId);
    });
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
      body: Column(
        children: [
          // ================= FAVORITE SONGS LIST =================
          Expanded(child: _buildFavoriteSongsList()),

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

  // ✅ Widget riêng cho FavoriteSongsList - tối ưu rebuild
  Widget _buildFavoriteSongsList() {
    return Selector<FavoriteProvider, Set<String>>(
      selector: (_, provider) => provider.favoriteSongIds,
      builder: (context, favoriteSongIds, _) {
        final songProvider = context.read<SongProvider>();

        final favoriteSongs = favoriteSongIds
            .map((id) {
              try {
                return songProvider.songs.firstWhere((s) => s.id == id);
              } catch (e) {
                return null;
              }
            })
            .whereType<Song>()
            .toList();

        if (favoriteSongs.isEmpty) {
          return const Center(child: Text("Không có bài hát yêu thích"));
        }

        return ListView.builder(
          itemCount: favoriteSongs.length,
          itemBuilder: (context, index) {
            final song = favoriteSongs[index];

            return ListTile(
              leading: Image.network(song.coverUrl, width: 50, height: 50),
              title: Text(song.title),
              subtitle: Text(song.artistName),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  final userId = authProvider.user?.uid ?? '';
                  context.read<FavoriteProvider>().toggleFavorite(
                    userId,
                    song.id,
                  );
                },
              ),
              onTap: () {
                final songProvider = context.read<SongProvider>();
                songProvider.playSongFromList(song, playlist: favoriteSongs);
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
