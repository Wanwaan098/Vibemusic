import 'package:flutter/material.dart';
import 'package:music_app/features/song/presentation/user/pages/song_detail_page.dart';
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/core/services/audio_player_service.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ TỐI ƯU: Dùng Selector chỉ rebuild khi song/showMiniPlayer thay đổi
    // Position stream sẽ rebuild StreamBuilder riêng, không rebuild toàn widget
    return Selector<SongProvider, (Song?, bool)>(
      selector: (_, provider) =>
          (provider.currentSong, provider.showMiniPlayer),
      builder: (context, data, _) {
        final song = data.$1;
        final showMiniPlayer = data.$2;
        final audio = context.read<SongProvider>().audio;

        if (song == null || !showMiniPlayer) {
          return const SizedBox();
        }

        return _buildMiniPlayerUI(context, song, audio);
      },
    );
  }

  Widget _buildMiniPlayerUI(
    BuildContext context,
    Song song,
    AudioPlayerService audio,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SongDetailPage(songId: song.id, fromMiniPlayer: true),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple.shade100],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.purple.shade100, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ PROGRESS riêng stream - không rebuild toàn widget
            StreamBuilder<Duration>(
              stream: audio.positionStream,
              builder: (_, snapshot) {
                final pos = snapshot.data ?? Duration.zero;
                final dur = audio.player.duration ?? Duration.zero;

                double value = 0;
                if (dur.inMilliseconds > 0) {
                  value = pos.inMilliseconds / dur.inMilliseconds;
                }

                return LinearProgressIndicator(
                  value: value.clamp(0, 1),
                  minHeight: 3,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation(
                    const Color.fromRGBO(156, 39, 176, 1), // ✅ tím
                  ),
                );
              },
            ),

            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.coverUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              title: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              subtitle: Text(
                song.artistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.purple.shade400),
              ),

              // ✅ NÚT TÍM Ở ĐÂY - PlayerState riêng stream
              trailing: StreamBuilder<PlayerState>(
                stream: audio.playerStateStream,
                builder: (_, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;

                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.purple, // ✅ tím
                      size: 36,
                    ),
                    onPressed: () {
                      if (audio.currentUrl != song.audioUrl) {
                        audio.playNew(song.audioUrl);
                      } else {
                        isPlaying ? audio.pause() : audio.play(song.audioUrl);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Import Song entity ở đầu file (nếu chưa có)
// import 'package:music_app/features/song/domain/entities/song.dart';
