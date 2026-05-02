import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_app/core/widgets/admin_sidebar.dart'; // ✅ ADD
import '../providers/song_manager_provider.dart';
import '../widgets/song_form_dialog.dart';
import 'package:music_app/core/services/audio_player_service.dart';

class ManageSongsPage extends StatefulWidget {
  const ManageSongsPage({super.key});

  @override
  State<ManageSongsPage> createState() => _ManageSongsPageState();
}

class _ManageSongsPageState extends State<ManageSongsPage> {
  final audioService = AudioPlayerService();

  bool isExpanded = false; // ✅ ADD

  String selectedGenre = "All";

  final List<String> genres = [
    "All",
    "Pop",
    "Ballad",
    "EDM",
    "Rock",
    "Hip Hop",
    "Rap",
    "R&B",
    "Acoustic",
    "Lo-fi",
    "Jazz",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<SongManagerProvider>().load(),
    );
  }

  void logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  void _confirmDelete(BuildContext context, String songId, String audioUrl,
      SongManagerProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xoá"),
        content: const Text("Bạn có chắc muốn xoá bài hát này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () async {
              if (audioService.currentUrl == audioUrl) {
                await audioService.stop();
              }

              await provider.delete(songId);

              Navigator.pop(context);
            },
            child: const Text(
              "Xoá",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongManagerProvider>();

    final songs = selectedGenre == "All"
        ? provider.songs
        : provider.songs.where((s) => s.genre == selectedGenre).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const SongFormDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Stack(
        children: [
          // ✅ CONTENT
          Positioned(
            top: 0,
            bottom: 0,
            left: 70,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (isExpanded) setState(() => isExpanded = false);
              },
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: selectedGenre,
                      decoration: const InputDecoration(
                        labelText: "Filter by Genre",
                        border: OutlineInputBorder(),
                      ),
                      items: genres
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGenre = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: StreamBuilder<PlayerState>(
                      stream: audioService.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final isPlaying =
                            playerState?.playing ?? false;

                        return ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];

                            final isCurrent =
                                audioService.currentUrl ==
                                    song.audioUrl;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  child: Image.network(
                                    song.coverUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            const Icon(
                                                Icons.music_note),
                                  ),
                                ),
                                title: Text(song.title),
                                subtitle: Text(
                                    "${song.artistName} • ${song.genre}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // PLAY
                                    IconButton(
                                      icon: Icon(
                                        (isCurrent && isPlaying)
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.green,
                                      ),
                                      onPressed: () async {
                                        if (isCurrent &&
                                            isPlaying) {
                                          await audioService.pause();
                                        } else {
                                          await audioService
                                              .play(
                                                  song.audioUrl);
                                        }
                                      },
                                    ),

                                    // EDIT
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              SongFormDialog(
                                                  song: song),
                                        );
                                      },
                                    ),

                                    // DELETE
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _confirmDelete(
                                          context,
                                          song.id,
                                          song.audioUrl,
                                          provider,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ SIDEBAR
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: AdminSidebar(
              isExpanded: isExpanded,
              onToggle: () =>
                  setState(() => isExpanded = !isExpanded),
              onLogout: logout,
            ),
          ),
        ],
      ),
    );
  }
}