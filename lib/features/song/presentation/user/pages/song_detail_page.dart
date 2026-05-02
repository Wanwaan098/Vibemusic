import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import 'package:music_app/core/services/audio_player_service.dart';
import 'package:music_app/features/artist/presentation/user/pages/artist_detail_page.dart';
import 'package:music_app/features/artist/presentation/user/providers/artist_viewer_provider.dart';
import 'package:music_app/injection_container.dart' as di;

class SongDetailPage extends StatefulWidget {
  final String songId;
  final bool fromMiniPlayer;

  const SongDetailPage({
    super.key,
    required this.songId,
    this.fromMiniPlayer = false,
  });

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  late AudioPlayerService audio; // ✅ dùng chung
  final ScrollController _scrollController = ScrollController();

  final Map<int, GlobalKey> lyricKeys = {};
  int _lastIndex = -1;
  bool _isUserSeeking = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<SongProvider>();
      audio = provider.audio; // ✅ dùng chung instance

      if (!widget.fromMiniPlayer) {
        await provider.loadSongDetail(widget.songId);

        final song = provider.currentSong;

        // ✅ CHỈ reset nếu KHÁC bài
        if (song != null && audio.currentUrl != song.audioUrl) {
          await audio.playNew(song.audioUrl);
        }
      }

      provider.bindAudio(audio);
    });
  }

  int _getLyricIndexByTime(double seconds, List lyrics) {
    int index = 0;
    for (int i = 0; i < lyrics.length; i++) {
      if (lyrics[i].time <= seconds) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }

  void _scrollToIndex(int index) {
    final key = lyricKeys[index];
    if (key == null) return;

    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.4,
    );
  }

  String formatTime(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();
    final song = provider.currentSong;

    if (song == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () {
            context.read<SongProvider>().showMini();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(song.coverUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    song.coverUrl,
                    height: 240,
                    width: 240,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  song.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    // ✅ Validate artistId before navigating
                    if (song.artistId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Artist ID not available"),
                        ),
                      );
                      return;
                    }
                     context.read<SongProvider>().showMini();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (_) => di.sl<ArtistViewerProvider>(),
                            ),
                            // ✅ Preserve SongProvider for mini player
                            ChangeNotifierProvider.value(value: provider),
                          ],
                          child: ArtistDetailPage(artistId: song.artistId),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    song.artistName,
                    style: const TextStyle(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // LYRICS
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: song.lyricLines.length,
                    itemBuilder: (_, i) {
                      final line = song.lyricLines[i];
                      lyricKeys[i] ??= GlobalKey();

                      final isActive = provider.currentLyric?.time == line.time;

                      return Container(
                        key: lyricKeys[i],
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          line.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isActive ? 20 : 16,
                            color: isActive ? Colors.white : Colors.white54,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                _buildBottomPlayer(song),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPlayer(song) {
    return Column(
      children: [
        StreamBuilder<Duration>(
          stream: audio.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = audio.player.duration ?? Duration.zero;

            final posSec = position.inMilliseconds / 1000;
            final durSec = duration.inMilliseconds / 1000;

            final safeMax = durSec <= 0 ? 1.0 : durSec;
            final safeValue = posSec.clamp(0.0, safeMax);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_isUserSeeking) return;

              final index = _getLyricIndexByTime(posSec, song.lyricLines);

              if (index != _lastIndex) {
                _lastIndex = index;
                _scrollToIndex(index);
              }
            });

            return Column(
              children: [
                Row(
                  children: [
                    StreamBuilder<PlayerState>(
                      stream: audio.playerStateStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data?.playing ?? false;

                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 34,
                          ),
                          onPressed: () {
                            if (audio.currentUrl != song.audioUrl) {
                              audio.playNew(song.audioUrl);
                            } else {
                              isPlaying
                                  ? audio.pause()
                                  : audio.play(song.audioUrl);
                            }
                          },
                        );
                      },
                    ),
                    Expanded(
                      child: Slider(
                        value: safeValue,
                        max: safeMax,
                        onChangeStart: (_) => _isUserSeeking = true,
                        onChanged: (v) {
                          audio.seek(
                            Duration(milliseconds: (v * 1000).toInt()),
                          );
                        },
                        onChangeEnd: (_) => _isUserSeeking = false,
                      ),
                    ),
                  ],
                ),

                // ✅ TIME LEFT - RIGHT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(position),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        formatTime(duration),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ],
    );
  }
}
