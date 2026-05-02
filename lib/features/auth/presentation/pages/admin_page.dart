/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void logout(BuildContext context) {
    context.read<AuthProvider>().logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Admin Panel",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings, size: 80),
          const SizedBox(height: 20),
          const Text(
            "Welcome Admin",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 30),
          AppButton(text: "Logout", onPressed: () => logout(context)),
        ],
      ),
    );
  }
}*/