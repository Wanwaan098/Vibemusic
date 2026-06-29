import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_gradient.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:provider/provider.dart';
import 'package:music_app/features/artist/presentation/user/providers/artist_viewer_provider.dart';
import 'package:music_app/features/album/presentation/providers/album_provider.dart';
import 'package:music_app/features/album/presentation/pages/album_detail_page.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/core/theme/app_colors.dart';

class ArtistDetailPage extends StatefulWidget {
  final String artistId;

  const ArtistDetailPage({super.key, required this.artistId});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (widget.artistId.isEmpty) return;
      final provider = context.read<ArtistViewerProvider>();
      await provider.loadArtistDetail(widget.artistId);
      context.read<AlbumProvider>().loadAlbumsByArtist(widget.artistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArtistViewerProvider>();
    final artist = provider.currentArtist;

    if (provider.errorMessage != null && !provider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "Error",
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                "Error loading artist",
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.isLoading || artist == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.purple)),
      );
    }

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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
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
                      Text(
                        artist.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          artist.biography,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // TAB MENU
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Bài hát",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTabIndex == 0
                                            ? AppColors.purple
                                            : AppColors.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_selectedTabIndex == 0)
                                      Container(
                                        height: 3,
                                        color: AppColors.purple,
                                        width: 30,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 1),
                                child: Column(
                                  children: [
                                    Text(
                                      "Album",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTabIndex == 1
                                            ? AppColors.purple
                                            : AppColors.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_selectedTabIndex == 1)
                                      Container(
                                        height: 3,
                                        color: AppColors.purple,
                                        width: 30,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // TAB CONTENT
                      _selectedTabIndex == 0
                          ? _buildSongsTab(provider)
                          : _buildAlbumsTab(),
                    ],
                  ),
                ),
              ),
            ),
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

  Widget _buildSongsTab(ArtistViewerProvider provider) {
    return Column(
      children: [
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
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${provider.artistSongs.length} bài",
                style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (provider.artistSongs.isEmpty)
          Padding(
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
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  context.read<SongProvider>().playSongFromList(
                    song,
                    playlist: provider.artistSongs,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongDetailPage(songId: song.id),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildAlbumsTab() {
    return Consumer<AlbumProvider>(
      builder: (context, albumProvider, _) {
        final albums = albumProvider.artistAlbums;
        if (albums.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  Icons.album_outlined,
                  size: 48,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Chưa có album nào",
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AlbumDetailPage(albumId: album.id, album: album),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      color: AppColors.surface,
                      child: Image.network(
                        album.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.album),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    album.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "${album.releaseYear}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
