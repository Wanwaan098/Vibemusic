import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/core/widgets/admin_sidebar.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/features/playlist/domain/entities/system_playlist.dart';
import 'package:music_app/features/playlist/presentation/providers/system_playlist_provider.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';

class ManageSystemPlaylistsPage extends StatefulWidget {
  const ManageSystemPlaylistsPage({super.key});

  @override
  State<ManageSystemPlaylistsPage> createState() =>
      _ManageSystemPlaylistsPageState();
}

class _ManageSystemPlaylistsPageState extends State<ManageSystemPlaylistsPage> {
  bool _isSidebarExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SystemPlaylistProvider>().loadPlaylists();
      context.read<SongProvider>().loadSongs();
    });
  }

  void _showCreatePlaylistDialog() {
    _showPlaylistFormDialog(null);
  }

  void _showEditPlaylistDialog(SystemPlaylist playlist) {
    _showPlaylistFormDialog(playlist);
  }

  void _showPlaylistFormDialog(SystemPlaylist? playlist) {
    final nameController = TextEditingController(text: playlist?.name ?? '');
    final descriptionController = TextEditingController(
      text: playlist?.description ?? '',
    );
    final thumbnailController = TextEditingController(
      text: playlist?.thumbnail ?? '',
    );
    final priorityController = TextEditingController(
      text: playlist?.priority.toString() ?? '0',
    );
    final searchController = TextEditingController();

    List<String> selectedSongIds = List.from(playlist?.songIds ?? []);
    List<dynamic> searchResults = [];

    final playlistProvider = context.read<SystemPlaylistProvider>();
    final songProvider = context.read<SongProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        final mqWidth = MediaQuery.of(dialogContext).size.width;
        final dialogWidth = mqWidth < 700 ? mqWidth * 0.95 : 600.0;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: StatefulBuilder(
              builder: (ctx, setState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist == null ? 'Tạo Playlist' : 'Sửa Playlist',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // BASIC INFO
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên Playlist',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.playlist_play),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Mô Tả',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: thumbnailController,
                        decoration: InputDecoration(
                          labelText: 'URL Thumbnail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.image),
                        ),
                        maxLines: 2,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      if (thumbnailController.text.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            thumbnailController.text,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priorityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Thứ Tự (Priority)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.sort),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Quản lý bài hát',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm bài hát (Tên / Nghệ sĩ)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() {
                                    searchController.clear();
                                    searchResults = [];
                                  }),
                                )
                              : null,
                        ),
                        onChanged: (query) {
                          setState(() {
                            if (query.isEmpty) {
                              searchResults = [];
                            } else {
                              final allSongs = songProvider.songs;
                              searchResults = allSongs
                                  .where(
                                    (song) =>
                                        song.title.toLowerCase().contains(
                                          query.toLowerCase(),
                                        ) ||
                                        song.artistName.toLowerCase().contains(
                                          query.toLowerCase(),
                                        ),
                                  )
                                  .toList();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      if (searchResults.isNotEmpty)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (_, idx) {
                              final song = searchResults[idx];
                              final isSelected = selectedSongIds.contains(
                                song.id,
                              );
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    song.coverUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                subtitle: Text(
                                  song.artistName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.add_circle_outline,
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  onPressed: () => setState(() {
                                    if (isSelected)
                                      selectedSongIds.remove(song.id);
                                    else
                                      selectedSongIds.add(song.id);
                                  }),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      const Text(
                        'Bài hát đã chọn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedSongIds.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Chưa chọn bài hát nào. Tìm kiếm và chọn bài để bắt đầu!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.purple),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: selectedSongIds.length,
                            itemBuilder: (_, idx) {
                              final songId = selectedSongIds[idx];
                              final allSongs = songProvider.songs;
                              final songIndex = allSongs.indexWhere(
                                (s) => s.id == songId,
                              );
                              if (songIndex == -1) return const SizedBox();
                              final song = allSongs[songIndex];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    song.coverUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                subtitle: Text(
                                  '${idx + 1}. ${song.artistName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => setState(
                                    () => selectedSongIds.remove(songId),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                            ),
                            onPressed: () async {
                              if (nameController.text.trim().isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '⚠️ Vui lòng nhập tên Playlist',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              if (descriptionController.text.trim().isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ Vui lòng nhập mô tả'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              if (thumbnailController.text.trim().isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '⚠️ Vui lòng nhập URL Thumbnail',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              if (selectedSongIds.isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '⚠️ Playlist nổi bật phải có ít nhất 1 bài hát',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final dialogNav = Navigator.of(dialogContext);

                              try {
                                if (playlist == null) {
                                  await playlistProvider.createPlaylist(
                                    name: nameController.text.trim(),
                                    description: descriptionController.text
                                        .trim(),
                                    thumbnail: thumbnailController.text.trim(),
                                    priority:
                                        int.tryParse(priorityController.text) ??
                                        0,
                                    songIds: selectedSongIds,
                                  );
                                  dialogNav.pop();
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Tạo playlist thành công',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  await playlistProvider.updatePlaylist(
                                    id: playlist.id,
                                    name: nameController.text.trim(),
                                    description: descriptionController.text
                                        .trim(),
                                    thumbnail: thumbnailController.text.trim(),
                                    priority:
                                        int.tryParse(priorityController.text) ??
                                        0,
                                    songIds: selectedSongIds,
                                  );
                                  dialogNav.pop();
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Cập nhật playlist thành công',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('❌ Lỗi: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              playlist == null ? 'Lưu' : 'Cập nhật',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ScaffoldMessenger chung của cả màn hình này
    final parentScaffoldMessenger = ScaffoldMessenger.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    if (isMobile) {
      // Mobile layout: use Drawer for sidebar and a single Scaffold
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Playlist Hệ thống'),
          centerTitle: true,
          backgroundColor: AppColors.purple,
        ),
        drawer: Drawer(
          child: AdminSidebar(
            isExpanded: true,
            onToggle: () => Navigator.pop(context),
            onLogout: () {},
          ),
        ),
        body: Consumer<SystemPlaylistProvider>(
          builder: (consumerContext, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.playlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.playlist_play,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có playlist nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.playlists.length,
              itemBuilder: (listContext, index) {
                final playlist = provider.playlists[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        playlist.thumbnail,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.album),
                        ),
                      ),
                    ),
                    title: Text(
                      playlist.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${playlist.songCount} bài hát • Priority: ${playlist.priority}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditPlaylistDialog(playlist),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (deleteDialogContext) => AlertDialog(
                                title: const Text('Xóa Playlist?'),
                                content: Text(
                                  'Bạn chắc chắn muốn xóa "${playlist.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      deleteDialogContext,
                                      false,
                                    ),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      deleteDialogContext,
                                      true,
                                    ),
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed ?? false) {
                              try {
                                await provider.removePlaylist(playlist.id);
                                parentScaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Xóa playlist thành công'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                parentScaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('❌ Lỗi xóa: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreatePlaylistDialog,
          backgroundColor: AppColors.purple,
          child: const Icon(Icons.add),
        ),
      );
    }

    // Desktop / larger screens: keep sidebar + content layout
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            onLogout: () {
              // Thêm logic xử lý đăng xuất ở đây
            },
          ),

          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Quản lý Playlist Hệ thống'),
                centerTitle: true,
                backgroundColor: AppColors.purple,
              ),
              body: Consumer<SystemPlaylistProvider>(
                builder: (consumerContext, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.playlists.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_play,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có playlist nào',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.playlists.length,
                    itemBuilder: (listContext, index) {
                      // Đổi tên context thành listContext
                      final playlist = provider.playlists[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              playlist.thumbnail,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.album),
                              ),
                            ),
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${playlist.songCount} bài hát • Priority: ${playlist.priority}',
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _showEditPlaylistDialog(playlist),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      // Sử dụng context an toàn từ cấp widget trên cùng
                                      context: context,
                                      builder: (deleteDialogContext) => AlertDialog(
                                        title: const Text('Xóa Playlist?'),
                                        content: Text(
                                          'Bạn chắc chắn muốn xóa "${playlist.name}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              deleteDialogContext,
                                            ),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final dialogNav = Navigator.of(
                                                deleteDialogContext,
                                              );

                                              // UX Tốt nhất: ĐÓNG popup ngay lập tức trước khi gọi API
                                              // Để tránh hiện tượng dính popup khi List ở dưới đã chuyển qua màn hình Loading.
                                              dialogNav.pop();

                                              try {
                                                await provider.removePlaylist(
                                                  playlist.id,
                                                );

                                                parentScaffoldMessenger
                                                    .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          '✅ Xóa playlist thành công',
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                              } catch (e) {
                                                parentScaffoldMessenger
                                                    .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '❌ Lỗi xóa: $e',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                              }
                                            },
                                            child: const Text(
                                              'Xóa',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _showCreatePlaylistDialog,
                backgroundColor: AppColors.purple,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
