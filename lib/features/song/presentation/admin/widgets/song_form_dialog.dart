import 'package:flutter/material.dart';
import 'package:music_app/features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:music_app/core/utils/lrc_parser.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import '../providers/song_manager_provider.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';

class SongFormDialog extends StatefulWidget {
  final Song? song;

  const SongFormDialog({super.key, this.song});

  @override
  State<SongFormDialog> createState() => _SongFormDialogState();
}

class _SongFormDialogState extends State<SongFormDialog> {
  final titleCtrl = TextEditingController();
  final artistCtrl = TextEditingController();
  final audioCtrl = TextEditingController();
  final coverCtrl = TextEditingController();
  final lyricCtrl = TextEditingController();

  List<String> previewLyrics = [];

  String selectedGenre = "Pop";
  String? selectedArtistId;

  final List<String> genres = [
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

    Future.microtask(() {
      context.read<ArtistManagerProvider>().fetchArtists();
    });

    if (widget.song != null) {
      titleCtrl.text = widget.song!.title;
      artistCtrl.text = widget.song!.artistName;
      audioCtrl.text = widget.song!.audioUrl;
      coverCtrl.text = widget.song!.coverUrl;
      lyricCtrl.text = widget.song!.lyricRaw;

      selectedGenre = widget.song!.genre;
      selectedArtistId = widget.song!.artistId;
    }

    coverCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = context.read<SongManagerProvider>();
    final artistProvider = context.watch<ArtistManagerProvider>();

    return Dialog(
      child: SizedBox(
        width: 600,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                widget.song == null ? "Add Song" : "Edit Song",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // TITLE
                      TextField(
                        controller: titleCtrl,
                        decoration:
                            const InputDecoration(labelText: "Title"),
                      ),

                      const SizedBox(height: 10),

                      // ✅ ARTIST DROPDOWN
                      DropdownSearch<Artist>(
                        items: artistProvider.artists,
                        itemAsString: (a) => a.name,

                        selectedItem: artistProvider.artists
                                .where((a) => a.id == selectedArtistId)
                                .isNotEmpty
                            ? artistProvider.artists.firstWhere(
                                (a) => a.id == selectedArtistId)
                            : null,

                        dropdownDecoratorProps:
                            const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Artist",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                        ),

                        onChanged: (artist) {
                          if (artist != null) {
                            artistCtrl.text = artist.name;
                            selectedArtistId = artist.id;
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // GENRE
                      DropdownButtonFormField<String>(
                        value: selectedGenre,
                        decoration:
                            const InputDecoration(labelText: "Genre"),
                        items: genres.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGenre = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // AUDIO
                      TextField(
                        controller: audioCtrl,
                        decoration:
                            const InputDecoration(labelText: "Audio URL"),
                      ),

                      // COVER
                      TextField(
                        controller: coverCtrl,
                        decoration:
                            const InputDecoration(labelText: "Cover URL"),
                      ),

                      const SizedBox(height: 10),

                      if (coverCtrl.text.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            coverCtrl.text,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // LRC
                      TextField(
                        controller: lyricCtrl,
                        maxLines: 6,
                        decoration:
                            const InputDecoration(labelText: "LRC"),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          final lines =
                              LrcParser.parseLines(lyricCtrl.text);

                          setState(() {
                            previewLyrics =
                                lines.map((e) => e.text).toList();
                          });
                        },
                        child: const Text("Preview Lyric"),
                      ),

                      const SizedBox(height: 10),

                      if (previewLyrics.isNotEmpty)
                        Container(
                          height: 120,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListView.builder(
                            itemCount: previewLyrics.length,
                            itemBuilder: (_, i) =>
                                Text(previewLyrics[i]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // SAVE
              ElevatedButton(
                onPressed: () async {
                  if (selectedArtistId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Vui lòng chọn Artist")),
                    );
                    return;
                  }

                  final meta =
                      LrcParser.parseMeta(lyricCtrl.text);
                  final lines =
                      LrcParser.parseLines(lyricCtrl.text);

                  final song = Song(
                    id: widget.song?.id ?? '',
                    title: titleCtrl.text,
                    titleLowercase:
                        titleCtrl.text.toLowerCase(),
                    artistId: selectedArtistId!,
                    artistName: artistCtrl.text,
                    genre: selectedGenre,
                    audioUrl: audioCtrl.text,
                    coverUrl: coverCtrl.text,
                    lyricRaw: lyricCtrl.text,
                    lyricMeta: meta,
                    lyricLines: lines,
                    duration: 0,
                    playCount:
                        widget.song?.playCount ?? 0,
                    releaseDate:
                        widget.song?.releaseDate ??
                            DateTime.now(),
                    createdAt:
                        widget.song?.createdAt ??
                            DateTime.now(),
                  );

                  if (widget.song == null) {
                    await songProvider.add(song);
                  } else {
                    await songProvider.update(song);
                  }

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}