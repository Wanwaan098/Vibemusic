import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/core/theme/app_gradient.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';

class AlbumDetailPage extends StatefulWidget {
  final String albumId;
  final Album album;

  const AlbumDetailPage({
    super.key,
    required this.albumId,
    required this.album,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  @override
  void initState() {
    super.initState();
    // ✅ FIX: Ensure songs are loaded when viewing album
    Future.microtask(() {
      final songProvider = context.read<SongProvider>();
      if (songProvider.songs.isEmpty) {
        songProvider.loadSongs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradient.background),
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Album Cover
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.surface,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.album.coverUrl,
                            height: 240,
                            width: 240,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Album Title
                      Text(
                        widget.album.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Release Year & Song Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.album.releaseYear}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            height: 4,
                            width: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.textGrey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Album',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      // Songs List Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bài hát trong album',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Consumer<SongProvider>(
                              builder: (context, songProvider, _) {
                                final albumSongs = songProvider.songs
                                    .where((s) => s.albumId == widget.albumId)
                                    .toList();
                                return Text(
                                  '${albumSongs.length} bài',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textGrey,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Songs List
                      _buildSongsList(),
                    ],
                  ),
                ),
              ),
            ),
            // Mini Player at Bottom
            Selector<SongProvider, (Song?, bool)>(
              selector: (_, p) => (p.currentSong, p.showMiniPlayer),
              builder: (context, data, _) {
                if (data.$1 == null || !data.$2) return const SizedBox();
                return const MiniPlayer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    return Consumer<SongProvider>(
      builder: (context, songProvider, _) {
        final albumSongs = songProvider.songs
            .where((s) => s.albumId == widget.albumId)
            .toList();

        if (albumSongs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  Icons.music_off_outlined,
                  size: 48,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có bài hát nào',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: albumSongs.length,
          itemBuilder: (context, index) {
            final song = albumSongs[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
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
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                song.artistName,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              onTap: () {
                // Play this song from album context (only album songs in skip queue)
                songProvider.playSongFromList(song, playlist: albumSongs);
                // Navigate to song detail
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
