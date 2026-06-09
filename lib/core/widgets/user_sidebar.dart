import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/core/theme/app_colors.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';

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
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    // ✅ helper check active
    bool isActive(String route) => currentRoute == route;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

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
                  const SizedBox(height: 20),

                  // ========== USER PROFILE SECTION ==========
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.purple.withOpacity(0.3),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: isExpanded ? 35 : 20,
                                backgroundColor: AppColors.purple.withOpacity(
                                  0.2,
                                ),
                                backgroundImage: user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: isExpanded ? 35 : 20,
                                        color: AppColors.purple,
                                      )
                                    : null,
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 8),
                                // User Name
                                if (user.name != null && user.name!.isNotEmpty)
                                  Text(
                                    user.name!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                // Email
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 15),

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
      },
    );
  }
}
