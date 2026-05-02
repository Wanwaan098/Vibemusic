import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/vibemusic_logo.dart';

import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!context.mounted) return;

      final user = authProvider.user;

      if (user?.role == "admin") {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AppScaffold(
      title: "",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const VibeMusicLogo(),
          const SizedBox(height: 40),
          AppTextField(controller: emailController, label: "Email"),
          const SizedBox(height: 16),
          AppTextField(
            controller: passwordController,
            label: "Password",
            obscure: true,
          ),
          const SizedBox(height: 24),
          isLoading
              ? const CircularProgressIndicator()
              : AppButton(text: "Login", onPressed: login),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text("Create account"),
          ),
        ],
      ),
    );
  }
}