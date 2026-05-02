import 'package:flutter/material.dart';
import 'package:music_app/features/song/domain/entities/song.dart';
import 'package:music_app/features/song/domain/usecases/add_song.dart';
import 'package:music_app/features/song/domain/usecases/delete_song.dart';
import 'package:music_app/features/song/domain/usecases/get_songs.dart';
import 'package:music_app/features/song/domain/usecases/update_song.dart';

class SongManagerProvider extends ChangeNotifier {
  final GetSongs getSongs;
  final AddSong addSong;
  final UpdateSong updateSong;
  final DeleteSong deleteSong;

  SongManagerProvider({
    required this.getSongs,
    required this.addSong,
    required this.updateSong,
    required this.deleteSong,
  });

  List<Song> songs = [];

  Future<void> load() async {
    songs = await getSongs();
    notifyListeners();
  }

  Future<void> add(Song song) async {
    await addSong(song);
    await load();
  }

  Future<void> update(Song song) async {
    await updateSong(song);
    await load();
  }

  Future<void> delete(String id) async {
    await deleteSong(id);
    await load();
  }
}