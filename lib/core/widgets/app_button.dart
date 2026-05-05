import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromRGBO(184, 42, 189, 1), Color.fromRGBO(192, 81, 236, 1)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(169, 46, 191, 0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),

        onPressed: onPressed,

        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
