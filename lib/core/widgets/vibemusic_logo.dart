import 'package:flutter/material.dart';

class VibeMusicLogo extends StatelessWidget {
  const VibeMusicLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.music_note, size: 70, color: Color.fromARGB(255, 223, 158, 241)),

        const SizedBox(height: 10),

        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 34,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),

            children: [
              TextSpan(
                text: "Vibe",
                style: TextStyle(color:  Color.fromARGB(255, 223, 158, 241)),
              ),
              TextSpan(
                text: "Music",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
