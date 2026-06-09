import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/vibemusic_logo.dart';

import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        name: nameController.text.trim(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Register Success")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AppScaffold(
      title: "",
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const VibeMusicLogo(),
          const SizedBox(height: 40),
          AppTextField(controller: nameController, label: "Họ tên"),
          const SizedBox(height: 16),
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
              : AppButton(text: "Register", onPressed: register),
        ],
      ),
    );
  }
}
