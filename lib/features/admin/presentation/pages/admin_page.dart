import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../admin/presentation/providers/admin_stats_provider.dart';
import '../../../../injection_container.dart' as di;

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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin'), centerTitle: true),
        drawer: Drawer(
          child: AdminSidebar(
            isExpanded: true,
            onToggle: () => Navigator.pop(context),
            onLogout: () => logout(context),
          ),
        ),
        body: SafeArea(
          child: ChangeNotifierProvider(
            create: (_) => di.sl<AdminStatsProvider>(),
            child: const AdminDashboardPage(),
          ),
        ),
      );
    }

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
              child: ChangeNotifierProvider(
                create: (_) => di.sl<AdminStatsProvider>(),
                child: const AdminDashboardPage(),
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
              onToggle: () => setState(() => isExpanded = !isExpanded),
              onLogout: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
