import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Các import của bạn giữ nguyên...
import '../../../../core/widgets/metric_card.dart';
import '../providers/admin_stats_provider.dart';
import '../widgets/top_songs_table.dart';
import 'package:music_app/features/admin/presentation/widgets/dashboard_charts_fl.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStatsProvider>().load();
    });
  }

  // Hàm tiện ích để tạo Card đồng nhất, đẹp mắt
  Widget _buildBeautifulCard({required Widget child}) {
    return Card(
      elevation: 2, // Tạo độ nổi nhẹ
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bo góc mềm mại hơn
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Tăng khoảng trống bên trong (padding)
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStatsProvider>(
      builder: (context, prov, _) {
        if (prov.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải dữ liệu: ${prov.error}',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: prov.load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tải lại trang'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final stats = prov.stats;

        final width = MediaQuery.of(context).size.width;
        final isMobile = width < 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0), // Tăng lề ngoài cho thoáng
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KHOẢNG METRIC CARDS
              if (!isMobile)
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Tổng số bài hát',
                        value: prov.isLoading ? '...' : '${stats?.totalSongs ?? 0}',
                        icon: Icons.music_note,
                        isLoading: prov.isLoading,
                      ),
                    ),
                    const SizedBox(width: 20), // Tăng khoảng cách giữa các card
                    Expanded(
                      child: MetricCard(
                        title: 'Tổng số album',
                        value: prov.isLoading ? '...' : '${stats?.totalAlbums ?? 0}',
                        icon: Icons.album,
                        isLoading: prov.isLoading,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MetricCard(
                        title: 'Tổng số nghệ sĩ',
                        value: prov.isLoading ? '...' : '${stats?.totalArtists ?? 0}',
                        icon: Icons.person,
                        isLoading: prov.isLoading,
                      ),
                    ),
                  ],
                )
              else
                // Mobile: stack metrics vertically with spacing
                Column(
                  children: [
                    MetricCard(
                      title: 'Tổng số bài hát',
                      value: prov.isLoading ? '...' : '${stats?.totalSongs ?? 0}',
                      icon: Icons.music_note,
                      isLoading: prov.isLoading,
                    ),
                    const SizedBox(height: 12),
                    MetricCard(
                      title: 'Tổng số album',
                      value: prov.isLoading ? '...' : '${stats?.totalAlbums ?? 0}',
                      icon: Icons.album,
                      isLoading: prov.isLoading,
                    ),
                    const SizedBox(height: 12),
                    MetricCard(
                      title: 'Tổng số nghệ sĩ',
                      value: prov.isLoading ? '...' : '${stats?.totalArtists ?? 0}',
                      icon: Icons.person,
                      isLoading: prov.isLoading,
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // 2. KHOẢNG CHARTS & TABLE
              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CỘT TRÁI: BIỂU ĐỒ (Flex 3 hoặc 5 để chiếm nhiều chỗ hơn) ---
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _buildBeautifulCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Top 5 bài hát theo lượt nghe',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 320, // TĂNG CHIỀU CAO LÊN ĐỂ KHÔNG BỊ TRÀN TEXT BÊN DƯỚI
                                  child: prov.isLoading || stats == null
                                      ? const Center(child: CircularProgressIndicator())
                                      : buildBarChart(stats.topSongs),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (stats?.distribution != null)
                            _buildBeautifulCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phân bố theo thể loại',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 250,
                                    child: buildPieChart(stats!.distribution!),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // --- CỘT PHẢI: BẢNG TOP 5 (Flex 4) ---
                    Expanded(
                      flex: 4,
                      child: _buildBeautifulCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top 5 chi tiết',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            prov.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : SizedBox(
                                    // Bọc Table trong Container và SingleChildScrollView để chống tràn phải
                                    width: double.infinity,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: TopSongsTable(songs: stats?.topSongs ?? []),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Mobile: stack charts then table
                Column(
                  children: [
                    _buildBeautifulCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top 5 bài hát theo lượt nghe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 260,
                            child: prov.isLoading || stats == null
                                ? const Center(child: CircularProgressIndicator())
                                : buildBarChart(stats.topSongs),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (stats?.distribution != null)
                      _buildBeautifulCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phân bố theo thể loại',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: buildPieChart(stats!.distribution!),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    _buildBeautifulCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top 5 chi tiết',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          prov.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  child: TopSongsTable(songs: stats?.topSongs ?? []),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}