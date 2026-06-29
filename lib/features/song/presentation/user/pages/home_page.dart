import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/core/theme/app_gradient.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:music_app/core/widgets/top_navbar.dart';
import 'package:music_app/features/playlist/presentation/providers/system_playlist_provider.dart';
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
    Future.microtask(() {
      context.read<SongProvider>().loadSongs();
      context.read<SystemPlaylistProvider>().loadPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: TopNavbar(
        onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
        onSearchPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
      drawer: UserSidebar(
        onLogout: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradient.background),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Lời chào Premium thượng lưu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chào buổi tối",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "Hôm nay bạn muốn nghe gì?",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  BannerCarousel(banners: banners),

                  const SizedBox(height: 32),

                  _buildPlaylistsSection(),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Bài hát mới",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildSongsList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ================= MINI PLAYER FIXED =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Consumer<SongProvider>(
                builder: (context, provider, _) {
                  if (provider.currentSong == null ||
                      !provider.showMiniPlayer) {
                    return const SizedBox.shrink();
                  }
                  return const MiniPlayer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PLAYLISTS DESIGN (LUXURY) =================
  Widget _buildPlaylistsSection() {
    return Consumer<SystemPlaylistProvider>(
      builder: (context, provider, _) {
        if (provider.playlists.isEmpty || provider.isLoading) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Playlist nổi bật",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // Sửa lỗi màu hardcode
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220, // Tăng nhẹ kích thước để tránh tràn chữ
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = provider.playlists[index];

                  return Container(
                    width: 145,
                    margin: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        try {
                          debugPrint(
                            'Navigating to system playlist: ${playlist.id}',
                          );
                          Navigator.pushNamed(
                            context,
                            '/system-playlist',
                            arguments: playlist.id,
                          );
                        } catch (e) {
                          debugPrint('Navigation error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi điều hướng: $e')),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Image có shadow mịn sâu
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                playlist.thumbnail,
                                width: 145,
                                height: 145,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Chữ căn lề trái sang trọng hơn căn giữa
                          Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Được tuyển chọn",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= SONG LIST DESIGN (PREMIUM ROW) =================
  Widget _buildSongsList() {
    return Consumer<SongProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: provider.songs.length,
          itemBuilder: (context, index) {
            final song = provider.songs[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () {
                  final songProvider = context.read<SongProvider>();
                  songProvider.playSongFromList(song);
                  songProvider.showMini();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongDetailPage(songId: song.id),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // Tạo hiệu ứng nền kính mờ nhẹ ôm lấy bài hát
                    color: AppColors.textPrimary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.textPrimary.withOpacity(0.02),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Ảnh bài hát bo tròn sang chảnh
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          song.coverUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thông tin bài hát
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nút Play tối giản dạng icon tròn tinh tế
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textPrimary.withOpacity(0.06),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded, // Dùng icon tròn mịn hơn
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
