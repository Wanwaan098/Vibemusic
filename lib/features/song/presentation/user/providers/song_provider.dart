import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/services/audio_player_service.dart';
import 'package:music_app/features/song/domain/entities/lyric_line.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/usecases/get_song.dart';
import 'package:music_app/features/song/domain/usecases/get_songs.dart';
import 'package:music_app/features/song/domain/usecases/increase_play_count.dart';
import 'package:music_app/features/song/domain/usecases/search_songs.dart';

enum PlayMode { normal, repeatAll, repeatOne, shuffle }

class SongProvider extends ChangeNotifier {
  final GetSongs getSongs;
  final GetSong getSong;
  final SearchSongs searchSongs;
  final IncreasePlayCount increasePlayCount;
  final AudioPlayerService audio;

  SongProvider({
    required this.getSongs,
    required this.getSong,
    required this.searchSongs,
    required this.increasePlayCount,
    required this.audio,
  }) {
    _playerStateSub = audio.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        nextSong(isAuto: true);
      }
    });
  }

  List<Song> songs = [];
  List<Song> originalPlaylist = [];
  List<Song> currentPlaylist = [];
  int currentSongIndex = -1;
  Song? currentSong;
  bool isLoading = false;

  // 🔥 MINI PLAYER STATE
  bool showMiniPlayer = false;

  // 🔥 PLAY MODE
  PlayMode playMode = PlayMode.normal;

  // 🔥 TIMER
  Timer? _timerCountdown;
  int? timerSeconds; // null = no timer, or seconds remaining

  LyricLine? currentLyric;
  StreamSubscription<Duration>? _sub;
  StreamSubscription<PlayerState>? _playerStateSub;

  // ================= LOAD =================
  Future<void> loadSongs() async {
    isLoading = true;
    notifyListeners();

    songs = await getSongs();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadSongDetail(String id) async {
    isLoading = true;
    notifyListeners();

    currentSong = await getSong(id);

    bindAudio(audio);

    isLoading = false;
    notifyListeners();
  }

  // ================= PLAY =================

  Future<void> playSongFromList(Song song, {List<Song>? playlist}) async {
    if (playlist != null) {
      originalPlaylist = List.from(playlist);
    } else {
      originalPlaylist = List.from(songs);
    }

    _updateCurrentPlaylist(song);

    currentSongIndex = currentPlaylist.indexWhere((s) => s.id == song.id);
    if (currentSongIndex == -1) {
      originalPlaylist = [song];
      _updateCurrentPlaylist(song);
      currentSongIndex = 0;
    }

    currentSong = song;

    showMiniPlayer = true;

    notifyListeners();

    await increasePlayCount(song.id);

    await audio.playNew(song.audioUrl);

    bindAudio(audio);
  }

  Future<void> playSongAtCurrentIndex(int index) async {
    if (index < 0 || index >= currentPlaylist.length) return;

    final song = currentPlaylist[index];
    currentSongIndex = index;
    currentSong = song;
    showMiniPlayer = true;

    notifyListeners();

    await increasePlayCount(song.id);
    await audio.playNew(song.audioUrl);

    bindAudio(audio);
  }

  void _updateCurrentPlaylist([Song? activeSong]) {
    final songToKeep = activeSong ?? currentSong;

    if (playMode == PlayMode.shuffle) {
      final shuffled = List<Song>.from(originalPlaylist)..shuffle();
      if (songToKeep != null) {
        shuffled.removeWhere((s) => s.id == songToKeep.id);
        shuffled.insert(0, songToKeep);
      }
      currentPlaylist = shuffled;
    } else {
      currentPlaylist = List.from(originalPlaylist);
    }

    if (songToKeep != null) {
      currentSongIndex = currentPlaylist.indexWhere(
        (s) => s.id == songToKeep.id,
      );
    }
  }

  void cyclePlayMode() {
    switch (playMode) {
      case PlayMode.normal:
        playMode = PlayMode.repeatAll;
        break;
      case PlayMode.repeatAll:
        playMode = PlayMode.repeatOne;
        break;
      case PlayMode.repeatOne:
        playMode = PlayMode.shuffle;
        break;
      case PlayMode.shuffle:
        playMode = PlayMode.normal;
        break;
    }

    _updateCurrentPlaylist();
    notifyListeners();
  }

  void setPlayMode(PlayMode mode) {
    playMode = mode;
    _updateCurrentPlaylist();
    notifyListeners();
  }

  Future<void> nextSong({bool isAuto = false}) async {
    if (currentPlaylist.isEmpty || currentSongIndex < 0) return;

    if (isAuto && playMode == PlayMode.repeatOne) {
      await audio.seek(Duration.zero);
      await audio.player.play();
      return;
    }

    int nextIndex = currentSongIndex + 1;
    if (nextIndex >= currentPlaylist.length) {
      if (isAuto && playMode == PlayMode.normal) {
        // Phát 1 lần toàn bộ danh sách rồi dừng
        await audio.stop();
        return;
      }
      nextIndex = 0;
    }

    await playSongFromList(
      currentPlaylist[nextIndex],
      playlist: originalPlaylist,
    );
  }

  Future<void> previousSong() async {
    if (currentPlaylist.isEmpty || currentSongIndex < 0) return;

    int prevIndex = currentSongIndex - 1;
    if (prevIndex < 0) {
      prevIndex = currentPlaylist.length - 1;
    }

    await playSongFromList(
      currentPlaylist[prevIndex],
      playlist: originalPlaylist,
    );
  }

  // ================= MINI PLAYER =================

  void showMini() {
    showMiniPlayer = true;
    notifyListeners();
  }

  void hideMini() {
    showMiniPlayer = false;
    notifyListeners();
  }

  // ================= TIMER =================

  void startTimer(int seconds) {
    timerSeconds = seconds;
    _timerCountdown?.cancel();

    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds! > 0) {
        timerSeconds = timerSeconds! - 1;
        notifyListeners();
      } else {
        // Auto pause when timer ends
        audio.pause();
        timerSeconds = null;
        _timerCountdown?.cancel();
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void cancelTimer() {
    _timerCountdown?.cancel();
    timerSeconds = null;
    notifyListeners();
  }

  String? getTimerDisplay() {
    if (timerSeconds == null) return null;
    final mins = timerSeconds! ~/ 60;
    final secs = timerSeconds! % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ================= SEARCH =================

  Future<void> search(String query) async {
    songs = await searchSongs(query);
    notifyListeners();
  }

  // ================= SYNC LYRIC =================

  void bindAudio(AudioPlayerService audio) {
    _sub?.cancel();

    _sub = audio.positionStream.listen((pos) {
      final seconds = pos.inMilliseconds / 1000;
      final lines = currentSong?.lyricLines ?? [];

      LyricLine? active;

      for (final l in lines) {
        if (l.time <= seconds) {
          active = l;
        } else {
          break;
        }
      }

      currentLyric = active;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _playerStateSub?.cancel();
    _timerCountdown?.cancel();
    super.dispose();
  }
}
