import 'package:flutter/material.dart';

class VibeMusicLogo extends StatelessWidget {
  const VibeMusicLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.music_note, size: 70, color: Color.fromRGBO(219, 50, 225, 1)),

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
                style: TextStyle(color:  Color.fromRGBO(219, 50, 225, 1)),
              ),
              TextSpan(
                text: "Music",
                style: TextStyle(color:Color.fromARGB(255, 241, 150, 248)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
