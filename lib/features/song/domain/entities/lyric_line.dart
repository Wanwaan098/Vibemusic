class LyricLine {
  final double time;
  final String text;

  LyricLine({
    required this.time,
    required this.text,
  });

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(
      time: (json['time'] as num).toDouble(),
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time,
      "text": text,
    };
  }
}