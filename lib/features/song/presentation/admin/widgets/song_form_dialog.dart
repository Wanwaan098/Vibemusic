import 'package:flutter/material.dart';
import 'package:music_app/features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';
import 'package:music_app/features/album/presentation/providers/album_provider.dart';
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
  String? selectedAlbumId;

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
      context.read<AlbumProvider>().loadAlbums();
    });

    if (widget.song != null) {
      titleCtrl.text = widget.song!.title;
      artistCtrl.text = widget.song!.artistName;
      audioCtrl.text = widget.song!.audioUrl;
      coverCtrl.text = widget.song!.coverUrl;
      lyricCtrl.text = widget.song!.lyricRaw;

      selectedGenre = widget.song!.genre;
      selectedArtistId = widget.song!.artistId;
      selectedAlbumId = widget.song!.albumId;
    }

    coverCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = context.read<SongManagerProvider>();
    final artistProvider = context.watch<ArtistManagerProvider>();
    final mqWidth = MediaQuery.of(context).size.width;
    final mqHeight = MediaQuery.of(context).size.height;
    final dialogWidth = mqWidth < 700 ? mqWidth * 0.95 : 600.0;
    final dialogHeight = mqHeight < 800 ? mqHeight * 0.9 : 700.0;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
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
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      const SizedBox(height: 10),

                      // ARTIST DROPDOWN
                      DropdownSearch<Artist>(
                        items: artistProvider.artists,
                        itemAsString: (a) => a.name,
                        selectedItem:
                            artistProvider.artists
                                .where((a) => a.id == selectedArtistId)
                                .isNotEmpty
                            ? artistProvider.artists.firstWhere(
                                (a) => a.id == selectedArtistId,
                              )
                            : null,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Artist",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        onChanged: (artist) {
                          if (artist != null) {
                            setState(() {
                              artistCtrl.text = artist.name;
                              selectedArtistId = artist.id;
                              selectedAlbumId = null; // Reset Album
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // ALBUM DROPDOWN
                      Consumer<AlbumProvider>(
                        builder: (context, albumProvider, _) {
                          final filteredAlbums = selectedArtistId != null
                              ? albumProvider.albums
                                    .where(
                                      (album) =>
                                          album.artistId == selectedArtistId,
                                    )
                                    .toList()
                              : [];

                          final bool isAlbumValid =
                              selectedAlbumId == null ||
                              filteredAlbums.any(
                                (a) => a.id == selectedAlbumId,
                              );

                          return DropdownButtonFormField<String?>(
                            value: isAlbumValid ? selectedAlbumId : null,
                            decoration: const InputDecoration(
                              labelText:
                                  "Album (Optional - for singles leave empty)",
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text("No Album (Single)"),
                              ),
                              ...filteredAlbums
                                  .map<DropdownMenuItem<String?>>(
                                    (album) => DropdownMenuItem<String?>(
                                      value: album.id,
                                      child: Text(album.title),
                                    ),
                                  )
                                  .toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedAlbumId = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // GENRE
                      DropdownButtonFormField<String>(
                        value: selectedGenre,
                        decoration: const InputDecoration(labelText: "Genre"),
                        items: genres.map((g) {
                          return DropdownMenuItem(value: g, child: Text(g));
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
                        decoration: const InputDecoration(
                          labelText: "Audio URL",
                        ),
                      ),

                      // COVER
                      TextField(
                        controller: coverCtrl,
                        decoration: const InputDecoration(
                          labelText: "Cover URL",
                        ),
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
                        decoration: const InputDecoration(labelText: "LRC"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final lines = LrcParser.parseLines(lyricCtrl.text);
                          setState(() {
                            previewLyrics = lines.map((e) => e.text).toList();
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
                            itemBuilder: (_, i) => Text(previewLyrics[i]),
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
                      const SnackBar(content: Text("Vui lòng chọn Artist")),
                    );
                    return;
                  }

                  final meta = LrcParser.parseMeta(lyricCtrl.text);
                  final lines = LrcParser.parseLines(lyricCtrl.text);

                  final song = Song(
                    id: widget.song?.id ?? '',
                    title: titleCtrl.text,
                    titleLowercase: titleCtrl.text.toLowerCase(),
                    artistId: selectedArtistId!,
                    artistName: artistCtrl.text,
                    albumId: selectedAlbumId,
                    genre: selectedGenre,
                    audioUrl: audioCtrl.text,
                    coverUrl: coverCtrl.text,
                    lyricRaw: lyricCtrl.text,
                    lyricMeta: meta,
                    lyricLines: lines,
                    duration: 0,
                    playCount: widget.song?.playCount ?? 0,
                    releaseDate: widget.song?.releaseDate ?? DateTime.now(),
                    createdAt: widget.song?.createdAt ?? DateTime.now(),
                  );

                  if (widget.song == null) {
                    await songProvider.add(song);
                  } else {
                    await songProvider.update(song);
                  }

                  // ✅ FIX: Đảm bảo màn hình Dialog chưa bị destroy trước khi call pop
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
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
