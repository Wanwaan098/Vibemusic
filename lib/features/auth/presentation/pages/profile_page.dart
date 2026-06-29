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
    _nameController = TextEditingController(text: authProvider.user?.name ?? '');
    _emailController = TextEditingController(text: authProvider.user?.email ?? '');
    _userIdController = TextEditingController(text: authProvider.user?.uid ?? '');
    _roleController = TextEditingController(text: authProvider.user?.role ?? '');
    _avatarUrlController = TextEditingController(text: authProvider.user?.avatarUrl ?? '');
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Cập nhật thông tin thành công!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final primaryColor = Colors.deepPurple;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Vui lòng đăng nhập để xem thông tin', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FA), // Nền sáng mịn màng
          appBar: TopNavbar(
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
            onSearchPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Tìm kiếm - Tính năng sắp có"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          drawer: UserSidebar(
            onLogout: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600), // Giới hạn độ rộng để đẹp trên Web/Tablet
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- BỘ PHẦN AVATAR ---
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                ? Icon(Icons.person, size: 65, color: primaryColor)
                                : null,
                          ),
                        ),
                        if (_isEditing)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name ?? 'Chưa đặt tên',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role?.toUpperCase() ?? 'USER',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- CARD THÔNG TIN CÁ NHÂN ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin tài khoản',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Colors.black12),
                          ),
                          
                          _buildInputField(
                            controller: _nameController,
                            label: 'Họ và tên',
                            icon: Icons.person_outline,
                            isReadOnly: !_isEditing,
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            controller: _emailController,
                            label: 'Địa chỉ Email',
                            icon: Icons.mail_outline,
                            isReadOnly: true,
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            controller: _userIdController,
                            label: 'Mã người dùng (User ID)',
                            icon: Icons.fingerprint,
                            isReadOnly: true,
                          ),
                          const SizedBox(height: 20),

                          if (_isEditing) ...[
                            _buildInputField(
                              controller: _avatarUrlController,
                              label: 'Đường dẫn ảnh đại diện (URL)',
                              icon: Icons.link_rounded,
                              isReadOnly: false,
                              hint: 'Dán link ảnh tại đây...',
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- HỆ THỐNG NÚT BẤM ---
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isEditing
                          ? Row(
                              key: const ValueKey('editing'),
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isLoading ? null : () => setState(() => _isEditing = false),
                                    icon: const Icon(Icons.close),
                                    label: const Text('Hủy'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      foregroundColor: Colors.grey[700],
                                      side: BorderSide(color: Colors.grey[300]!),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _saveChanges,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.check),
                                    label: const Text('Lưu lại'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ElevatedButton.icon(
                              key: const ValueKey('viewing'),
                              onPressed: () => setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Chỉnh sửa hồ sơ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(56),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widget giúp tạo form nhập liệu gọn gàng và đồng bộ
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isReadOnly,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          maxLines: label.contains('URL') ? null : 1,
          style: TextStyle(
            color: isReadOnly ? Colors.black54 : Colors.black87,
            fontWeight: isReadOnly ? FontWeight.normal : FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey[400] : Colors.deepPurple, size: 22),
            suffixIcon: isReadOnly ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey) : null,
            filled: true,
            fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}