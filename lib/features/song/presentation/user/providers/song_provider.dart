import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/core/services/audio_player_service.dart';
import 'package:music_app/features/song/domain/entities/lyric_line.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/usecases/get_song.dart';
import 'package:music_app/features/song/domain/usecases/get_songs.dart';
import 'package:music_app/features/song/domain/usecases/increase_play_count.dart';
import 'package:music_app/features/song/domain/usecases/search_songs.dart';

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
  });

  List<Song> songs = [];
  Song? currentSong;
  bool isLoading = false;

  // 🔥 MINI PLAYER STATE
  bool showMiniPlayer = false;

  LyricLine? currentLyric;
  StreamSubscription<Duration>? _sub;

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

  Future<void> playSongFromList(Song song) async {
    final isSameSong = currentSong?.id == song.id;

    currentSong = song;

    // ❗ QUAN TRỌNG:
    // Không hiện mini khi đang vào màn hình detail
    showMiniPlayer = false;

    notifyListeners();

    await increasePlayCount(song.id);

    if (isSameSong) {
      // 🔥 reset nếu cùng bài
      await audio.playNew(song.audioUrl);
    } else {
      // 🔥 bài mới
      await audio.playNew(song.audioUrl);
    }

    bindAudio(audio);
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
    super.dispose();
  }
}