import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_gradient.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/artist/presentation/user/providers/artist_viewer_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/core/theme/app_colors.dart'; // Đã thêm import theme của bạn

class ArtistDetailPage extends StatefulWidget {
  final String artistId;

  const ArtistDetailPage({super.key, required this.artistId});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (widget.artistId.isEmpty) {
        print("❌ Error: artistId is empty");
        return;
      }
      final provider = context.read<ArtistViewerProvider>();
      await provider.loadArtistDetail(widget.artistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArtistViewerProvider>();
    final artist = provider.currentArtist;

    // TRẠNG THÁI LỖI
    if (provider.errorMessage != null && !provider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Error", style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                "Error loading artist data", 
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary)
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage ?? "Unknown error", 
                style: const TextStyle(color: AppColors.textGrey)
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
            ],
          ),
        ),
      );
    }

    // TRẠNG THÁI LOADING
    if (provider.isLoading || artist == null) {
      return const Scaffold(
        backgroundColor: AppColors.background, // Đổi màu nền loading
        body: Center(
          child: CircularProgressIndicator(color: AppColors.purple), // Đổi màu xoay
        ),
      );
    }

    // TRẠNG THÁI HIỂN THỊ DỮ LIỆU
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // Để trong suốt để hiển thị gradient của body
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), // Đổi màu icon back
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        // SỬ DỤNG GRADIENT TỪ APP_COLORS
        decoration: const BoxDecoration(
          gradient: AppGradient.background,
        ),
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // AVATAR: BO TRÒN HOÀN TOÀN + VIỀN TRẮNG NỔI BẬT + ĐỔ BÓNG TÍM
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface, // Đổi sang viền trắng của theme
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withOpacity(0.2), // Đổ bóng màu tím nhạt
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            artist.avatarUrl,
                            height: 220,
                            width: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TÊN NGHỆ SĨ
                      Text(
                        artist.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary, // Đổi màu chữ sang tối
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // BIO / TIỂU SỬ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          artist.biography,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey, // Đổi màu tiểu sử
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // TIÊU ĐỀ LIST BÀI HÁT
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Bài hát phổ biến",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary, // Đổi màu
                              ),
                            ),
                            Text(
                              "${provider.artistSongs.length} bài",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey, // Đổi màu
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // DANH SÁCH BÀI HÁT
                      if (provider.artistSongs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              const Icon(Icons.music_off_outlined, size: 48, color: AppColors.textGrey),
                              const SizedBox(height: 16),
                              const Text(
                                "Chưa có bài hát nào",
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.artistSongs.length,
                          itemBuilder: (context, index) {
                            final song = provider.artistSongs[index];

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
                                  color: AppColors.textPrimary, // Chữ tối
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  song.artistName,
                                  style: const TextStyle(
                                    color: AppColors.textGrey, // Chữ xám
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert, color: AppColors.textGrey), // Nút tùy chọn xám
                                onPressed: () {
                                  // Todo: Mở menu thêm (tuỳ chọn)
                                },
                              ),
                              onTap: () {
                                final songProvider = context.read<SongProvider>();
                                final isSameSong = songProvider.currentSong?.id == song.id;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SongDetailPage(
                                      songId: song.id,
                                      fromMiniPlayer: isSameSong,
                                    ),
                                  ),
                                );

                                Future.microtask(() async {
                                  if (isSameSong) {
                                    await songProvider.audio.playNew(song.audioUrl);
                                  } else {
                                    await songProvider.playSongFromList(song);
                                  }
                                });
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // MINI PLAYER
            Consumer<SongProvider>(
              builder: (context, provider, _) {
                if (provider.currentSong == null || !provider.showMiniPlayer) {
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
}