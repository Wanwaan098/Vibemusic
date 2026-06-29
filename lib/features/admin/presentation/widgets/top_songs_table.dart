import 'package:flutter/material.dart';
import 'package:music_app/features/admin/domain/entities/admin_stats.dart';

class TopSongsTable extends StatelessWidget {
  final List<TopSong> songs;

  const TopSongsTable({Key? key, required this.songs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu để hiển thị'));
    }

    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('STT')),
          DataColumn(label: Text('')),
          DataColumn(label: Text('Tên bài hát')),
          DataColumn(label: Text('Nghệ sĩ')),
          DataColumn(label: Text('Lượt nghe')),
          DataColumn(label: Text('Hành động')),
        ],
        rows: List.generate(songs.length, (i) {
          final s = songs[i];
          return DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(
                s.thumbnailUrl != null
                    ? Image.network(
                        s.thumbnailUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(width: 40, height: 40),
              ),
              DataCell(Text(s.title)),
              DataCell(Text(s.artistName)),
              DataCell(Text('${s.playCount}')),
              DataCell(
                TextButton(
                  onPressed: () {
                    // Navigate to detail - left as placeholder
                  },
                  child: const Text('Xem chi tiết'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
