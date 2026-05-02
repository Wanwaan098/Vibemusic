import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/core/theme/app_gradient.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import 'song_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSidebarExpanded = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> banners = [
    "https://raw.githubusercontent.com/Wanwaan098/music-app-assets/main/%E1%BA%A2nh%20ch%E1%BB%A5p%20m%C3%A0n%20h%C3%ACnh%202026-05-02%20234743.png",
    "https://raw.githubusercontent.com/Wanwaan098/music-app-assets/main/%E1%BA%A2nh%20ch%E1%BB%A5p%20m%C3%A0n%20h%C3%ACnh%202026-05-02%20234825.png",
    "https://raw.githubusercontent.com/Wanwaan098/music-app-assets/main/%E1%BA%A2nh%20ch%E1%BB%A5p%20m%C3%A0n%20h%C3%ACnh%202026-05-02%20234849.png",
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() => context.read<SongProvider>().loadSongs());

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % banners.length;

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();

    return Scaffold(
      backgroundColor: AppColors.background, // 🔥 nền pastel bạn đưa
      body: Row(
        children: [
          // ================= SIDEBAR =================
          UserSidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            onLogout: () =>
                Navigator.pushReplacementNamed(context, '/'),
          ),

          // ================= MAIN =================
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradient.background, // 🔥 gradient nền
              ),
              child: Column(
                children: [
                  // 🔥 REMOVE GAP TOP
                  SizedBox(
                    height: 0,
                  ),

                  // ================= BANNER (FULL TOP) =================
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: banners.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          banners[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),

                  // ================= DOT INDICATOR =================
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        banners.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.deepPurple
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),

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
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: provider.songs.length,
                            itemBuilder: (context, index) {
                              final song = provider.songs[index];

                              return Card(
                                elevation: 0,
                                color: Colors.white,
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15),
                                  side: BorderSide(
                                      color: Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.all(8),
                                  leading: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    child: Image.network(
                                      song.coverUrl,
                                      width: 55,
                                      height: 55,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    song.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(song.artistName),
                                  trailing: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.deepPurple,
                                    size: 32,
                                  ),

                                  onTap: () {
                                    final songProvider =
                                        context.read<SongProvider>();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SongDetailPage(
                                          songId: song.id,
                                        ),
                                      ),
                                    );

                                    Future.microtask(() {
                                      songProvider
                                          .playSongFromList(song);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),

                  // ================= MINI PLAYER =================
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
            ),
          ),
        ],
      ),
    );
  }
}