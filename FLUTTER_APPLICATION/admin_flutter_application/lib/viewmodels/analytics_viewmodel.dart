import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final _service = AnalyticsService();
  int totalBookings = 0;
  int pendingQuotations = 0;
  int completedBookings = 0;
  double totalRevenue = 0;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    totalBookings = await _service.getTotalBookings();
    pendingQuotations = await _service.getPendingQuotations();
    totalRevenue = await _service.getTotalRevenue();
    completedBookings = await _service.getCompletedBookings();
    loading = false;
    notifyListeners();
  }
}