import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';

class UserSidebar extends StatelessWidget {
  final VoidCallback? onLogout;

  const UserSidebar({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    // ✅ helper check active
    bool isActive(String route) => currentRoute == route;

    // ✅ TỐI ƯU: Selector chỉ rebuild khi user ID/name/avatar thay đổi, không rebuild trên mọi AuthProvider change
    return Selector<AuthProvider, (String, String?, String?)>(
      selector: (_, authProvider) => (
        authProvider.user?.uid ?? '',
        authProvider.user?.name,
        authProvider.user?.avatarUrl,
      ),
      builder: (context, userData, _) {
        final user = context.read<AuthProvider>().user;

        return Drawer(
          backgroundColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ========== USER PROFILE SECTION ==========
              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close drawer first
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.purple.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: AppColors.purple.withOpacity(0.2),
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 35,
                                    color: AppColors.purple,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          // User Name
                          if (user.name != null && user.name!.isNotEmpty)
                            Text(
                              user.name!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            )
                          else
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // HOME
              ListTile(
                selected: isActive('/home'),
                selectedTileColor: AppColors.purple.withOpacity(0.15),
                selectedColor: AppColors.purple,
                leading: const Icon(Icons.home),
                title: const Text("Trang chủ"),
                onTap: () {
                  Navigator.pop(context); // Close drawer
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
                title: const Text("Playlist"),
                onTap: () {
                  Navigator.pop(context); // Close drawer
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
                title: const Text("Yêu thích"),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  if (!isActive('/favorites')) {
                    Navigator.pushReplacementNamed(context, '/favorites');
                  }
                },
              ),

              const Spacer(),

              // LOGOUT
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  onLogout?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 15),
                      const Text(
                        "Đăng xuất",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
