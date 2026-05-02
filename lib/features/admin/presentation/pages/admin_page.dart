import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/admin_sidebar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isExpanded = false;

  void logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAIN CONTENT
          Positioned(
            top: 0,
            bottom: 0,
            left: 70,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (isExpanded) setState(() => isExpanded = false);
              },
              child: const Center(
                child: Text(
                  "Welcome Admin",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),

          // SIDEBAR
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: AdminSidebar(
              isExpanded: isExpanded,
              onToggle: () =>
                  setState(() => isExpanded = !isExpanded),
              onLogout: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}