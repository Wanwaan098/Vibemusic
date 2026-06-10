import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/core/widgets/top_navbar.dart';
import 'package:music_app/core/widgets/user_sidebar.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _userIdController;
  late TextEditingController _roleController;
  late TextEditingController _avatarUrlController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(
      text: authProvider.user?.name ?? '',
    );
    _emailController = TextEditingController(
      text: authProvider.user?.email ?? '',
    );
    _userIdController = TextEditingController(
      text: authProvider.user?.uid ?? '',
    );
    _roleController = TextEditingController(
      text: authProvider.user?.role ?? '',
    );
    _avatarUrlController = TextEditingController(
      text: authProvider.user?.avatarUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    _roleController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim().isEmpty
            ? null
            : _avatarUrlController.text.trim(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thông tin đã được lưu')));
      setState(() => _isEditing = false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Vui lòng đăng nhập')),
          );
        }

        return Scaffold(
          key: scaffoldKey,
          appBar: TopNavbar(
            onMenuPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
            onSearchPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tìm kiếm - Tính năng sắp có")),
              );
            },
          ),
          drawer: UserSidebar(
            onLogout: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Profile Form
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin cá nhân',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // Email Field (read-only)
                      TextField(
                        controller: _emailController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Name Field
                      TextField(
                        controller: _nameController,
                        readOnly: !_isEditing,
                        decoration: InputDecoration(
                          labelText: 'Tên',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: _isEditing
                              ? Colors.white
                              : Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // User ID (read-only)
                      TextField(
                        controller: _userIdController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'User ID',
                          prefixIcon: const Icon(Icons.fingerprint),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Role (read-only)
                      TextField(
                        controller: _roleController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: const Icon(Icons.admin_panel_settings),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Avatar URL Field
                      TextField(
                        controller: _avatarUrlController,
                        readOnly: !_isEditing,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'URL Ảnh đại diện',
                          prefixIcon: const Icon(Icons.image),
                          hintText: 'Dán link URL ảnh (ví dụ: https://...)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: _isEditing
                              ? Colors.white
                              : Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Action Buttons
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => setState(() => _isEditing = false),
                          icon: const Icon(Icons.close),
                          label: const Text('Hủy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveChanges,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Lưu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa thông tin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
