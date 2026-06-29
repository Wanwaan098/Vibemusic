import 'package:flutter/material.dart';
import 'package:music_app/features/album/presentation/widgets/album_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/presentation/providers/album_provider.dart';
import 'package:music_app/features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';
import 'package:music_app/core/widgets/admin_sidebar.dart';

class ManageAlbumsPage extends StatefulWidget {
  const ManageAlbumsPage({super.key});

  @override
  State<ManageAlbumsPage> createState() => _ManageAlbumsPageState();
}

class _ManageAlbumsPageState extends State<ManageAlbumsPage> {
  bool _isSidebarExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AlbumProvider>().loadAlbums();
      context.read<ArtistManagerProvider>().fetchArtists();
    });
  }

  void _showAddAlbumDialog() {
    final albumProvider = context.read<AlbumProvider>();
    final pageContext = context;

    showDialog(
      context: context,
      builder: (_) => AlbumFormDialog(
        onSubmit: (title, artistId, coverUrl, releaseYear) {
          albumProvider.createAlbum(
            title: title,
            artistId: artistId,
            coverUrl: coverUrl,
            releaseYear: releaseYear,
          );
          ScaffoldMessenger.of(pageContext).showSnackBar(
            SnackBar(
              content: Text('✅ Thêm album "$title" thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(pageContext);
        },
      ),
    );
  }

  void _showEditAlbumDialog(Album album) {
    final albumProvider = context.read<AlbumProvider>();
    final pageContext = context;

    showDialog(
      context: context,
      builder: (_) => AlbumFormDialog(
        initialAlbum: album,
        onSubmit: (title, artistId, coverUrl, releaseYear) {
          albumProvider.editAlbum(
            id: album.id,
            title: title,
            artistId: artistId,
            coverUrl: coverUrl,
            releaseYear: releaseYear,
          );
          ScaffoldMessenger.of(pageContext).showSnackBar(
            SnackBar(
              content: Text('✅ Cập nhật album "$title" thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(pageContext);
        },
      ),
    );
  }

  void _deleteAlbum(Album album) {
    final albumProvider = context.read<AlbumProvider>();
    final pageContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Album'),
        content: Text('Bạn chắc chắn muốn xóa album "${album.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              albumProvider.removeAlbum(album.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(pageContext).showSnackBar(
                SnackBar(
                  content: Text('✅ Xóa album "${album.title}" thành công'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Scaffold gốc bọc một Row để chứa Sidebar và Nội dung chính
    return Scaffold(
      body: Row(
        children: [
          // 1. Admin Sidebar bên trái
          AdminSidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            onLogout: () {
              // Thêm logic đăng xuất của bạn ở đây
              // Ví dụ: context.read<AuthProvider>().logout(); Navigator.pushReplacementNamed...
            },
          ),

          // 2. Nội dung chính bên phải (Expanded để chiếm phần diện tích còn lại)
          Expanded(
            child: Scaffold( // Dùng Scaffold con để quản lý AppBar và FAB cho riêng vùng bên phải
              appBar: AppBar(
                title: const Text('Quản lý Album'),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.purple,
                elevation: 1,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _showAddAlbumDialog,
                backgroundColor: AppColors.purple,
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: Consumer<AlbumProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.albums.isEmpty) {
                    return const Center(
                      child: Text('Chưa có album nào. Nhấn + để thêm album mới.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.albums.length,
                    itemBuilder: (context, index) {
                      final album = provider.albums[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              album.coverUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.album),
                              ),
                            ),
                          ),
                          title: Text(album.title),
                          subtitle: Text('${album.releaseYear}'),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('Sửa'),
                                onTap: () => _showEditAlbumDialog(album),
                              ),
                              PopupMenuItem(
                                child: const Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () => _deleteAlbum(album),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}