import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradient {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      Color(0xFFF3E8FF), // pastel purple nhẹ
      Color(0xFFEDE9FE), // lavender nhẹ
    ],
  );

  static const header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.purple,
      Color(0xFFC4B5FD),
    ],
  );
}