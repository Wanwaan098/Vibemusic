import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors.dart';

class UserSidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onLogout;

  const UserSidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Lấy route hiện tại (fix null)
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

              // HOME
              ListTile(
                selected: isActive('/home'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.home),
                title: isExpanded ? const Text("Trang chủ") : null,
                onTap: () {
                  if (!isActive('/home')) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),

              // PLAYLISTS
              ListTile(
                selected: isActive('/playlists'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.queue_music),
                title: isExpanded ? const Text("Playlist") : null,
                onTap: () {
                  if (!isActive('/playlists')) {
                    Navigator.pushReplacementNamed(context, '/playlists');
                  }
                },
              ),

              // FAVORITES
              ListTile(
                selected: isActive('/favorites'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.favorite),
                title: isExpanded ? const Text("Yêu thích") : null,
                onTap: () {
                  if (!isActive('/favorites')) {
                    Navigator.pushReplacementNamed(context, '/favorites');
                  }
                },
              ),

              // PROFILE
              ListTile(
                selected: isActive('/profile'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.person),
                title: isExpanded ? const Text("Hồ sơ") : null,
                onTap: () {
                  if (!isActive('/profile')) {
                    Navigator.pushReplacementNamed(context, '/profile');
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
