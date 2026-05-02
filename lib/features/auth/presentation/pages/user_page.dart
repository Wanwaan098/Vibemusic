/*import 'package:flutter/material.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/usecases/login_user.dart';
import 'login_page.dart';

class UserPage extends StatelessWidget {
  final LoginUser loginUser;

  const UserPage({super.key, required this.loginUser});

  void logout(BuildContext context) async {
    try {
      await loginUser.logout(); 
      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(loginUser: loginUser),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "User Page",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80),
          const SizedBox(height: 20),
          const Text(
            "Welcome User",
            style: TextStyle(fontSize: 24, fontFamily: "Poppins"),
          ),
          const SizedBox(height: 30),
          AppButton(text: "Logout", onPressed: () => logout(context)),
        ],
      ),
    );
  }
}*/