import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;

  const TopNavbar({
    super.key,
    required this.onMenuPressed,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.purple),
        onPressed: onMenuPressed,
        tooltip: 'Menu',
      ),
      title: const Text(
        'Music App',
        style: TextStyle(
          color: AppColors.purple,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.purple),
          onPressed: onSearchPressed,
          tooltip: 'Tìm kiếm',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
