import 'package:flutter/material.dart';
import '../../domain/entities/admin_stats.dart';

Widget buildBarChart(List<TopSong> topSongs) {
  if (topSongs.isEmpty)
    return const Center(child: Text('Chưa có dữ liệu lượt nghe để thống kê.'));

  final maxVal = topSongs
      .map((s) => s.playCount)
      .fold<int>(0, (p, n) => n > p ? n : p);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: topSongs.map((s) {
        final height = maxVal > 0 ? (s.playCount / maxVal) * 160 : 0.0;
        return Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${s.playCount}'),
              const SizedBox(height: 6),
              Container(width: 28, height: height, color: Colors.blue),
              const SizedBox(height: 6),
              Text(
                s.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '(${s.artistName})',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

Widget buildPieChart(Map<String, int> dist) {
  if (dist.isEmpty)
    return const Center(child: Text('Chưa có dữ liệu để hiển thị'));

  final total = dist.values.fold<int>(0, (p, n) => p + n);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: dist.entries.map((e) {
      final pct = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              color:
                  Colors.primaries[dist.keys.toList().indexOf(e.key) %
                      Colors.primaries.length],
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('${e.key}: ${e.value} ($pct%)')),
          ],
        ),
      );
    }).toList(),
  );
}
