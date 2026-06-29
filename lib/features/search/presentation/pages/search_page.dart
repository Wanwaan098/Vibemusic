import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/core/theme/app_gradient.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'package:music_app/features/search/presentation/providers/search_provider.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';
import 'package:music_app/features/album/presentation/providers/album_provider.dart';
import 'package:music_app/features/playlist/presentation/providers/system_playlist_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();

    Future.microtask(() async {
      _searchFocus.requestFocus();

      try {
        // Load data từ các providers khác
        final searchProvider = context.read<SearchProvider>();
        final songProvider = context.read<SongProvider>();
        final artistProvider = context.read<ArtistManagerProvider>();
        final albumProvider = context.read<AlbumProvider>();
        final playlistProvider = context.read<SystemPlaylistProvider>();

        // 🔥 Đảm bảo dữ liệu đã được load
        if (songProvider.songs.isEmpty) {
          await songProvider.loadSongs();
        }
        if (artistProvider.artists.isEmpty) {
          try {
            await artistProvider.fetchArtists();
          } catch (e) {
            debugPrint('Error loading artists: $e');
          }
        }
        if (albumProvider.albums.isEmpty) {
          try {
            await albumProvider.loadAlbums();
          } catch (e) {
            debugPrint('Error loading albums: $e');
          }
        }
        if (playlistProvider.playlists.isEmpty) {
          try {
            await playlistProvider.loadPlaylists();
          } catch (e) {
            debugPrint('Error loading playlists: $e');
          }
        }

        // Set dữ liệu cho SearchProvider
        debugPrint('📊 Setting search data:');
        debugPrint('   - Songs: ${songProvider.songs.length}');
        debugPrint('   - Artists: ${artistProvider.artists.length}');
        debugPrint('   - Albums: ${albumProvider.albums.length}');
        debugPrint('   - Playlists: ${playlistProvider.playlists.length}');

        searchProvider.setAllSongs(songProvider.songs);
        searchProvider.setAllArtists(artistProvider.artists);
        searchProvider.setAllAlbums(albumProvider.albums);
        searchProvider.setAllPlaylists(playlistProvider.playlists);

        // Initialize search history
        await searchProvider.initialize();
      } catch (e) {
        debugPrint('Error initializing search page: $e');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        final hasResults = searchProvider.searchQuery.isNotEmpty;
        final isWaitingForSearch = !hasResults;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: AppGradient.background,
                ),
                child: Column(
                  children: [
                    // ================= TOP BAR =================
                    _buildTopBar(context, searchProvider),

                    // ================= CONTENT =================
                    Expanded(
                      child: isWaitingForSearch
                          ? _buildSearchHistory(context, searchProvider)
                          : _buildSearchResults(context, searchProvider),
                    ),
                  ],
                ),
              ),

              // ================= MINI PLAYER =================
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
      },
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar(BuildContext context, SearchProvider searchProvider) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Search Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      searchProvider.clearSearch();
                    } else {
                      searchProvider.search(value);
                    }
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      searchProvider.addToHistory(value);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Nhập tên bài hát, nghệ sĩ, album...',
                    hintStyle: TextStyle(
                      color: AppColors.textGrey.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textGrey,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Cancel Button
            GestureDetector(
              onTap: () {
                _searchController.clear();
                searchProvider.clearSearch();
                Navigator.pop(context);
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH HISTORY STATE =================
  Widget _buildSearchHistory(
    BuildContext context,
    SearchProvider searchProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử tìm kiếm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (searchProvider.searchHistory.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text(
                          'Xóa lịch sử?',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Bạn có chắc muốn xóa tất cả lịch sử tìm kiếm không?',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Hủy',
                              style: TextStyle(color: AppColors.purple),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              searchProvider.clearHistory();
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Xóa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    Icons.delete_rounded,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // History Chips
          if (searchProvider.searchHistory.isEmpty)
            Center(
              child: Text(
                'Không có lịch sử tìm kiếm',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchProvider.searchHistory.map((query) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightPurple, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _searchController.text = query;
                          searchProvider.search(query);
                        },
                        child: Text(
                          query,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          searchProvider.removeFromHistory(query);
                        },
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ================= SEARCH RESULTS STATE =================
  Widget _buildSearchResults(
    BuildContext context,
    SearchProvider searchProvider,
  ) {
    return Column(
      children: [
        // Tabs
        _buildTabs(searchProvider),

        // Results
        Expanded(
          child: searchProvider.isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _buildResultsList(context, searchProvider),
        ),
      ],
    );
  }

  // ================= TABS =================
  Widget _buildTabs(SearchProvider searchProvider) {
    final tabs = [
      ('Tất cả', SearchTab.all),
      ('Bài hát', SearchTab.songs),
      ('Playlist', SearchTab.playlists),
      ('Album', SearchTab.albums),
      ('Nghệ sĩ', SearchTab.artists),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: tabs.map((tab) {
          final isActive = searchProvider.selectedTab == tab.$2;
          return GestureDetector(
            onTap: () => searchProvider.selectTab(tab.$2),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    tab.$1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textGrey,
                    ),
                  ),
                  if (isActive)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: 30,
                      decoration: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= RESULTS LIST =================
  Widget _buildResultsList(
    BuildContext context,
    SearchProvider searchProvider,
  ) {
    final results = searchProvider.getCurrentResults();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy kết quả',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];

        if (item is Song) {
          return _buildSongItem(context, item);
        } else if (item is Artist) {
          return _buildArtistItem(context, item);
        } else if (item is Album) {
          return _buildAlbumItem(context, item);
        } else if (item is SystemPlaylist) {
          return _buildPlaylistItem(context, item);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ================= RESULT ITEMS =================
  Widget _buildSongItem(BuildContext context, Song song) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          final songProvider = context.read<SongProvider>();
          songProvider.playSongFromList(song);
          songProvider.showMini();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SongDetailPage(songId: song.id)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.02),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
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
                      color: AppColors.lightPurple,
                      child: Icon(
                        Icons.music_note,
                        color: AppColors.purple,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),

              // Menu Icon
              Icon(
                Icons.more_vert_rounded,
                color: AppColors.textGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtistItem(BuildContext context, Artist artist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          try {
            Navigator.pushNamed(context, '/artist', arguments: artist.id);
          } catch (e) {
            debugPrint('Navigation error: $e');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.02),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              ClipOval(
                child: Image.network(
                  artist.avatarUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD6BCFA),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.purple,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Artist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nghệ sĩ',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumItem(BuildContext context, Album album) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          try {
            Navigator.pushNamed(context, '/album', arguments: album.id);
          } catch (e) {
            debugPrint('Navigation error: $e');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.02),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Album Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  album.coverUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: AppColors.lightPurple,
                      child: Icon(
                        Icons.album,
                        color: AppColors.purple,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Album Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Album • ${album.releaseYear}',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(BuildContext context, SystemPlaylist playlist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          try {
            Navigator.pushNamed(
              context,
              '/system-playlist',
              arguments: playlist.id,
            );
          } catch (e) {
            debugPrint('Navigation error: $e');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.02),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  playlist.thumbnail,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: AppColors.lightPurple,
                      child: Icon(
                        Icons.playlist_play,
                        color: AppColors.purple,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Playlist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 4),
                    Text(
                      '${playlist.songCount} bài hát',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
