import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance =
      AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  String? _currentUrl;

  String? get currentUrl => _currentUrl;

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream;

  Stream<Duration> get positionStream =>
      _player.positionStream;

  Stream<Duration?> get durationStream =>
      _player.durationStream;

  // ✅ PLAY (reuse nếu cùng bài)
  Future<void> play(String url) async {
    try {
      if (_currentUrl != url) {
        await _player.setUrl(url);
        _currentUrl = url;
      }
      await _player.play();
    } catch (e) {
      print("Audio error: $e");
    }
  }

  // ✅ FIX CHÍNH: luôn reset + play bài mới
  Future<void> playNew(String url) async {
    try {
      await _player.stop();              // 🔥 stop bài cũ
      await _player.setUrl(url);         // 🔥 load bài mới
      _currentUrl = url;

      await _player.seek(Duration.zero); // 🔥 reset time
      await _player.play();              // 🔥 auto play
    } catch (e) {
      print("Audio error: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
  }

  Future<void> seek(Duration pos) async {
    await _player.seek(pos);
  }
}