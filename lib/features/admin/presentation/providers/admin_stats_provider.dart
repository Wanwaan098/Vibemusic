import 'package:flutter/material.dart';
import 'package:music_app/features/admin/domain/entities/admin_stats.dart';
import 'package:music_app/features/admin/domain/usecases/get_admin_stats.dart';

class AdminStatsProvider extends ChangeNotifier {
  final GetAdminStats getAdminStats;

  AdminStatsProvider({required this.getAdminStats});

  AdminStats? stats;
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      stats = await getAdminStats();
    } catch (e) {
      error = e is AdminDataException ? e.message : e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
