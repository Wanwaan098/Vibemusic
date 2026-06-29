import 'package:flutter/material.dart';
import '../../domain/entities/admin_stats.dart';

Widget buildBarChart(List<TopSong> topSongs) {
  // Stubbed simple UI for web to avoid importing fl_chart which may be incompatible
  if (topSongs.isEmpty)
    return const Center(child: Text('Chưa có dữ liệu lượt nghe để thống kê.'));

  return ListView(
    scrollDirection: Axis.horizontal,
    children: topSongs.map((s) {
      return Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              s.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              height: (s.playCount / (topSongs.first.playCount + 1)) * 100,
              width: 40,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text('${s.playCount}'),
          ],
        ),
      );
    }).toList(),
  );
}

Widget buildPieChart(Map<String, int> dist) {
  if (dist.isEmpty)
    return const Center(child: Text('Chưa có dữ liệu để hiển thị'));
  // Simple legend stub
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: dist.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
  );
}
