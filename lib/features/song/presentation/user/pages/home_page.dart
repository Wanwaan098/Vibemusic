import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/core/theme/app_gradient.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:music_app/core/widgets/top_navbar.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import '../widgets/banner_carousel.dart';
import 'song_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> banners = [
    "https://raw.githubusercontent.com/Wanwaan098/music-app-assets/main/%E1%BA%A2nh%20ch%E1%BB%A5p%20m%C3%A0n%20h%C3%ACnh%202026-05-02%20234743.png",
    "https://raw.githubusercontent.com/Wanwaan098/music-app-assets/main/%E1%BA%A2nh%20ch%E1%BB%A5p%20m%C3%A0n%20h%C3%ACnh%202026-05-02%20234825.png",
    "https://raw.githubusercontent.com/Wanwaan098/music-app-assets/main/%E1%BA%A2nh%20ch%E1%BB%A5p%20m%C3%A0n%20h%C3%ACnh%202026-05-02%20234849.png",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SongProvider>().loadSongs());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradient.background),
        child: Column(
          children: [
            // ✅ BannerCarousel quản lý state riêng, không ảnh hưởng Drawer
            BannerCarousel(banners: banners),

            const SizedBox(height: 20),

            // ================= TITLE =================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bài hát mới",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ================= LIST SONG =================
            Expanded(child: _buildSongsList()),

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
      ),
    );
  }

  // ✅ Widget riêng cho SongsList - tối ưu rebuild
  Widget _buildSongsList() {
    return Selector<SongProvider, (bool, List)>(
      selector: (_, provider) => (provider.isLoading, provider.songs),
      builder: (context, data, _) {
        final isLoading = data.$1;
        final songs = data.$2;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];

            return Card(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    song.coverUrl,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(song.artistName),
                trailing: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.deepPurple,
                  size: 32,
                ),
                onTap: () {
                  final songProvider = context.read<SongProvider>();

                  // Close drawer before navigation
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongDetailPage(songId: song.id),
                    ),
                  );

                  Future.microtask(() {
                    songProvider.playSongFromList(song);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
