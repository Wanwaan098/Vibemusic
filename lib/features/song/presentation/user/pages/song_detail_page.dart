import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import 'package:music_app/core/services/audio_player_service.dart';
import 'package:music_app/features/artist/presentation/user/pages/artist_detail_page.dart';
import 'package:music_app/features/artist/presentation/user/providers/artist_viewer_provider.dart';
import 'package:music_app/features/favorite/presentation/providers/favorite_provider.dart';
import 'package:music_app/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:music_app/features/auth/presentation/providers/auth_provider.dart';
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
  AudioPlayerService get audio => context.read<SongProvider>().audio;
  final ScrollController _scrollController = ScrollController();

  final Map<int, GlobalKey> lyricKeys = {};
  int _lastIndex = -1;
  bool _isUserSeeking = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final songProvider = context.read<SongProvider>();

      if (!widget.fromMiniPlayer) {
        await songProvider.loadSongDetail(widget.songId);

        final song = songProvider.currentSong;
        if (song != null && audio.currentUrl != song.audioUrl) {
          await audio.playNew(song.audioUrl);
        }
      }

      songProvider.bindAudio(audio);

      // Load favorites on init
      // Get user ID - you might get this from AuthProvider
      // For now, using a placeholder - update with actual user ID
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

  // ============ DIALOGS ============

  void _showTimerSubmenu() {
    final songProvider = context.read<SongProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.white),
            title: const Text("10 phút", style: TextStyle(color: Colors.white)),
            onTap: () {
              songProvider.startTimer(10 * 60);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.white),
            title: const Text("30 phút", style: TextStyle(color: Colors.white)),
            onTap: () {
              songProvider.startTimer(30 * 60);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.white),
            title: const Text("1 giờ", style: TextStyle(color: Colors.white)),
            onTap: () {
              songProvider.startTimer(60 * 60);
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.close, color: Colors.red),
            title: const Text(
              "Hủy hẹn giờ",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              songProvider.cancelTimer();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    final songProvider = context.read<SongProvider>();
    final authProvider = context.read<AuthProvider>();
    final song = songProvider.currentSong;

    if (song == null) return;

    // Always load fresh playlists for current user
    final userId = authProvider.user?.uid ?? '';
    Future.microtask(() {
      playlistProvider.loadPlaylists(userId);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Thêm vào Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<PlaylistProvider>(
            builder: (context, plProvider, _) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: plProvider.playlists.length + 1,
                itemBuilder: (context, index) {
                  if (index == plProvider.playlists.length) {
                    return ListTile(
                      leading: const Icon(Icons.add, color: Colors.cyan),
                      title: const Text(
                        "Tạo Playlist Mới",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showCreatePlaylistDialog();
                      },
                    );
                  }

                  final playlist = plProvider.playlists[index];
                  final isSongInPlaylist = playlist.songIds.contains(song.id);

                  return ListTile(
                    title: Text(
                      playlist.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${playlist.songIds.length} bài hát${isSongInPlaylist ? ' (đã có bài này)' : ''}",
                      style: TextStyle(
                        color: isSongInPlaylist
                            ? Colors.red[300]
                            : Colors.white70,
                      ),
                    ),
                    trailing: isSongInPlaylist
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: isSongInPlaylist
                        ? null
                        : () {
                            playlistProvider.addSongToPlaylistLocal(
                              playlist.id,
                              song.id,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Đã thêm vào ${playlist.name}"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showPlaylistDialog() {
    final playlistProvider = context.read<PlaylistProvider>();
    final songProvider = context.read<SongProvider>();
    final authProvider = context.read<AuthProvider>();
    final song = songProvider.currentSong;

    if (song == null) return;

    // Always load fresh playlists for current user
    final userId = authProvider.user?.uid ?? '';
    Future.microtask(() {
      playlistProvider.loadPlaylists(userId);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Add to Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<PlaylistProvider>(
            builder: (context, plProvider, _) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: plProvider.playlists.length + 1,
                itemBuilder: (context, index) {
                  if (index == plProvider.playlists.length) {
                    return ListTile(
                      leading: const Icon(Icons.add, color: Colors.cyan),
                      title: const Text(
                        "Create New Playlist",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showCreatePlaylistDialog();
                      },
                    );
                  }

                  final playlist = plProvider.playlists[index];
                  return ListTile(
                    title: Text(
                      playlist.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${playlist.songIds.length} songs",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      playlistProvider.addSongToPlaylistLocal(
                        playlist.id,
                        song.id,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Added to ${playlist.name}")),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "New Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Playlist name",
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final playlistProvider = context.read<PlaylistProvider>();
                final authProvider = context.read<AuthProvider>();
                final userId = authProvider.user?.uid ?? '';
                await playlistProvider.createNewPlaylist(
                  userId,
                  controller.text,
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();
    final song = provider.currentSong;
    final timerDisplay = provider.getTimerDisplay();

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
            // ✅ Fix: Try pop, if fail fallback to home
            try {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            } catch (e) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        actions: [
          // Timer Display
          if (timerDisplay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text(
                  timerDisplay,
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
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
                const SizedBox(height: 15),

                // LYRICS - EXPANDED
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

                // ========== CONTROL BUTTONS ==========
                _buildControlButtons(provider, song),

                // ========== PLAYER CONTROLS ==========
                _buildBottomPlayer(song, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(SongProvider provider, song) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Play Mode Button - 1 nút cycling
          InkWell(
            onTap: () => provider.cyclePlayMode(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getPlayModeIcon(provider.playMode),
                  color: Colors.cyan,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  _getPlayModeLabel(provider.playMode),
                  style: const TextStyle(color: Colors.cyan, fontSize: 10),
                ),
              ],
            ),
          ),

          // Favorite Button
          Consumer<FavoriteProvider>(
            builder: (context, favProvider, _) {
              final isFav = favProvider.isFavoriteSong(song.id);
              return InkWell(
                onTap: () {
                  final authProvider = context.read<AuthProvider>();
                  final userId = authProvider.user?.uid ?? '';
                  favProvider.toggleFavorite(userId, song.id);
                },
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                  size: 28,
                ),
              );
            },
          ),

          // Timer Button
          InkWell(
            onTap: _showTimerSubmenu,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.timerSeconds != null
                      ? Icons.timer
                      : Icons.timer_outlined,
                  color: provider.timerSeconds != null
                      ? Colors.cyan
                      : Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Hẹn giờ",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),

          // Add to Playlist Button
          InkWell(
            onTap: () => _showAddToPlaylistDialog(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.playlist_add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Thêm playlist",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),

          // Queue / Upcoming Songs Button
          InkWell(
            onTap: () => _showUpcomingSongs(context, provider),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.queue_music,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Danh sách",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlayModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.normal:
        return Icons.arrow_right_alt;
      case PlayMode.repeatAll:
        return Icons.repeat;
      case PlayMode.repeatOne:
        return Icons.repeat_one;
      case PlayMode.shuffle:
        return Icons.shuffle;
    }
  }

  String _getPlayModeLabel(PlayMode mode) {
    switch (mode) {
      case PlayMode.normal:
        return "Phát 1 lần";
      case PlayMode.repeatAll:
        return "Lặp tất cả";
      case PlayMode.repeatOne:
        return "Lặp 1 bài";
      case PlayMode.shuffle:
        return "Ngẫu nhiên";
    }
  }

  Widget _buildBottomPlayer(song, SongProvider provider) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 34,
                      ),
                      onPressed: () {
                        provider.previousSong();
                      },
                    ),
                    StreamBuilder<PlayerState>(
                      stream: audio.playerStateStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data?.playing ?? false;

                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_circle_fill,
                            color: Colors.white,
                            size: 48,
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
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 34,
                      ),
                      onPressed: () {
                        provider.nextSong();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
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

  void _showUpcomingSongs(BuildContext context, SongProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Determine context: from playlist or from home
        final isFromPlaylist =
            provider.originalPlaylist.length < provider.songs.length &&
            provider.originalPlaylist.isNotEmpty;

        final contextLabel = isFromPlaylist ? "Playlist" : "Tất cả bài hát";

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Danh sách phát",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$contextLabel (${provider.currentPlaylist.length} bài)",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Chế độ: ${_getPlayModeLabel(provider.playMode)}",
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.currentPlaylist.length,
                  itemBuilder: (context, index) {
                    final song = provider.currentPlaylist[index];
                    final isPlaying = index == provider.currentSongIndex;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          song.coverUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: TextStyle(
                          color: isPlaying ? Colors.cyan : Colors.white,
                          fontWeight: isPlaying
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        song.artistName,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: isPlaying
                          ? const Icon(Icons.music_note, color: Colors.cyan)
                          : Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                      onTap: () {
                        provider.playSongFromList(
                          song,
                          playlist: provider.originalPlaylist,
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
