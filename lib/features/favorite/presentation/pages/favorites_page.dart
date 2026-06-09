import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/favorite/presentation/providers/favorite_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isSidebarExpanded = false;

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
    final favProvider = context.watch<FavoriteProvider>();
    final songProvider = context.watch<SongProvider>();

    final favoriteSongs = favProvider.favoriteSongIds
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
                  title: const Text("Yêu thích"),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),
                Expanded(
                  child: favoriteSongs.isEmpty
                      ? const Center(child: Text("Không có bài hát yêu thích"))
                      : ListView.builder(
                          itemCount: favoriteSongs.length,
                          itemBuilder: (context, index) {
                            final song = favoriteSongs[index];

                            return ListTile(
                              leading: Image.network(
                                song.coverUrl,
                                width: 50,
                                height: 50,
                              ),
                              title: Text(song.title),
                              subtitle: Text(song.artistName),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  final authProvider = context
                                      .read<AuthProvider>();
                                  final userId = authProvider.user?.uid ?? '';
                                  favProvider.toggleFavorite(userId, song.id);
                                },
                              ),
                              onTap: () {
                                songProvider.playSongFromList(
                                  song,
                                  playlist: favoriteSongs,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SongDetailPage(songId: song.id),
                                  ),
                                );
                              },
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
}
