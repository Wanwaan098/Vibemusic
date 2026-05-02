import 'package:music_app/features/song/domain/entities/lyric_line.dart';

class LrcParser {
  static Map<String, dynamic> parseMeta(String raw) {
    final meta = <String, dynamic>{};

    final regex = RegExp(r'\[(\w+):(.+)\]');
    for (var match in regex.allMatches(raw)) {
      meta[match.group(1)!] = match.group(2);
    }

    return meta;
  }

  static List<LyricLine> parseLines(String raw) {
    final lines = <LyricLine>[];

    final regex = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');

    for (var match in regex.allMatches(raw)) {
      final min = int.parse(match.group(1)!);
      final sec = double.parse(match.group(2)!);

      lines.add(
        LyricLine(
          time: min * 60 + sec,
          text: match.group(3)?.trim() ?? '',
        ),
      );
    }

    return lines;
  }
}