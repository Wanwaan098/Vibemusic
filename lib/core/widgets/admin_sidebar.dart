import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onLogout;

  const AdminSidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    this.onLogout,
  });
  //haha
  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    // ✅ helper check active
    bool isActive(String route) => currentRoute == route;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 260 : 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: isExpanded ? 260 : 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // TOGGLE
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.menu_open : Icons.menu,
                    color: AppColors.purple,
                  ),
                  onPressed: onToggle,
                ),
              ),

              const SizedBox(height: 10),

              // DASHBOARD
              ListTile(
                selected: isActive('/admin'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.dashboard),
                title: isExpanded ? const Text("Dashboard") : null,
                onTap: () {
                  if (!isActive('/admin')) {
                    Navigator.pushReplacementNamed(context, '/admin');
                  }
                },
              ),

              // ARTISTS
              ListTile(
                selected: isActive('/admin/artists'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.person),
                title: isExpanded ? const Text("Quản lý nghệ sĩ") : null,
                onTap: () {
                  if (!isActive('/admin/artists')) {
                    Navigator.pushReplacementNamed(context, '/admin/artists');
                  }
                },
              ),

              // SONGS
              ListTile(
                selected: isActive('/admin/songs'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.music_note),
                title: isExpanded ? const Text("Quản lý kho nhạc") : null,
                onTap: () {
                  if (!isActive('/admin/songs')) {
                    Navigator.pushReplacementNamed(context, '/admin/songs');
                  }
                },
              ),

              // ALBUMS
              ListTile(
                selected: isActive('/admin/albums'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.album),
                title: isExpanded ? const Text("Quản lý album") : null,
                onTap: () {
                  if (!isActive('/admin/albums')) {
                    Navigator.pushReplacementNamed(context, '/admin/albums');
                  }
                },
              ),

              // PLAYLISTS
              ListTile(
                selected: isActive('/admin/playlists'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.playlist_play),
                title: isExpanded ? const Text("Quản lý playlist") : null,
                onTap: () {
                  if (!isActive('/admin/playlists')) {
                    Navigator.pushReplacementNamed(context, '/admin/playlists');
                  }
                },
              ),

              const Spacer(),

              // LOGOUT
              GestureDetector(
                onTap: onLogout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: isExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      if (isExpanded) ...[
                        const SizedBox(width: 15),
                        const Text(
                          "Đăng xuất",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
