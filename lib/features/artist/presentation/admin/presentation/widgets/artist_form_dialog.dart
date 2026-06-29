import 'package:flutter/material.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:provider/provider.dart';
import '../providers/artist_manager_provider.dart';

class ArtistFormDialog extends StatefulWidget {
  final Artist? artist;

  const ArtistFormDialog({super.key, this.artist});

  @override
  State<ArtistFormDialog> createState() => _ArtistFormDialogState();
}

class _ArtistFormDialogState extends State<ArtistFormDialog> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.artist != null) {
      nameController.text = widget.artist!.name;
      bioController.text = widget.artist!.biography;
      avatarController.text = widget.artist!.avatarUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ArtistManagerProvider>();
    final mqWidth = MediaQuery.of(context).size.width;
    final dialogWidth = mqWidth < 700 ? mqWidth * 0.95 : 600.0;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        width: dialogWidth, // adaptive width
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 TITLE
              Text(
                widget.artist == null ? "Add Artist" : "Update Artist",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 👤 PREVIEW IMAGE
              AnimatedBuilder(
                animation: avatarController,
                builder: (context, _) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: ClipOval(
                      child: avatarController.text.isNotEmpty
                          ? Image.network(
                              avatarController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.person, size: 50);
                              },
                            )
                          : const Icon(Icons.person, size: 50),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 📝 NAME
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // 📝 BIO
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Biography",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // 🖼 AVATAR URL
              TextField(
                controller: avatarController,
                onChanged: (_) => setState(() {}), // 👉 realtime preview
                decoration: const InputDecoration(
                  labelText: "Avatar URL",
                  border: OutlineInputBorder(),
                  hintText: "Paste image link here...",
                ),
              ),

              const SizedBox(height: 20),

              // 🔘 BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: () async {
                      final artist = Artist(
                        id: widget.artist?.id ?? '',
                        name: nameController.text,
                        biography: bioController.text,
                        avatarUrl: avatarController.text,
                        createdAt: DateTime.now(),
                      );

                      if (widget.artist == null) {
                        await provider.addArtist(artist);
                      } else {
                        await provider.updateArtist(artist);
                      }

                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
