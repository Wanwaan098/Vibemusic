// Conditional export: re-export fl_chart implementation on non-web, stub on web
export 'dashboard_charts_fl.dart'
    if (dart.library.html) 'dashboard_charts_stub.dart';

// Exposes:
// Widget buildBarChart(List<TopSong> topSongs)
// Widget buildPieChart(Map<String,int> dist)
