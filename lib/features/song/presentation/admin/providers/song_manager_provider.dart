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

    // ✅ FIX: Đợi Database hoàn tất index/sync dữ liệu trước khi lấy về.
    // Nếu không có delay, hàm getSongs() có thể bốc trúng data cũ.
    // Tăng delay từ 600ms → 1000ms để đảm bảo database đã xử lý xong
    await Future.delayed(const Duration(milliseconds: 1000));
    await load();
  }

  Future<void> update(Song song) async {
    await updateSong(song);

    // ✅ CRITICAL FIX: Luôn reload dữ liệu sau update (không dựa vào local update)
    // Lý do: Server có thể thêm/sửa timestamps, updateCount hoặc các trường khác
    // Local update không bao giờ đủ - phải lấy fresh data từ database
    // Tương tự như add(), chờ đủ thời gian rồi reload
    await Future.delayed(const Duration(milliseconds: 1000));
    await load();
  }

  Future<void> delete(String id) async {
    await deleteSong(id);

    // Chủ động xoá bài hát khỏi list cục bộ
    songs.removeWhere((s) => s.id == id);
    songs = List.from(songs); // Làm mới tham chiếu danh sách
    notifyListeners(); // Báo cho UI rebuild lập tức
  }
}
