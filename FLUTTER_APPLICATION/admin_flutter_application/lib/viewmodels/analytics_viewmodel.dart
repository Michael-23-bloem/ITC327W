import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final _service = AnalyticsService();

  int ongoingDeals = 0;
  int pastDeals = 0;
  int uniqueClients = 0;
  int awaitingDecision = 0;
  double confirmedRevenue = 0;
  List<MonthlyDealCount> monthlyDealCounts = const [];
  List<EventTypeCount> eventTypeCounts = const [];
  bool loading = false;
  String? error;

  String get aiTip => _generateTip();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final snapshot = await _service.loadSnapshot();
      ongoingDeals = snapshot.ongoingDeals;
      pastDeals = snapshot.pastDeals;
      uniqueClients = snapshot.uniqueClients;
      awaitingDecision = snapshot.awaitingDecision;
      confirmedRevenue = snapshot.confirmedRevenue;
      monthlyDealCounts = snapshot.monthlyDealCounts;
      eventTypeCounts = snapshot.eventTypeCounts;
    } catch (e) {
      debugPrint('Analytics load failed: $e');
      error = 'Could not load analytics. Pull to retry.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String _generateTip() {
    if (monthlyDealCounts.every((m) => m.count == 0) && ongoingDeals + pastDeals == 0) {
      return 'No deals recorded yet. Share your portfolio to start attracting enquiries.';
    }

    final recent = monthlyDealCounts.isNotEmpty ? monthlyDealCounts.last.count : 0;
    final prior = monthlyDealCounts.length >= 2
        ? monthlyDealCounts[monthlyDealCounts.length - 2].count
        : 0;

    if (recent > prior) {
      return 'Deals are trending up this month — follow up on open quotations while demand is high.';
    }
    if (recent < prior && prior > 0) {
      return 'Deals dipped compared to last month. A promo on past client favourites could lift bookings.';
    }
    if (ongoingDeals > pastDeals) {
      return 'You have more ongoing deals than closed ones — prioritise pending quotations to convert them faster.';
    }
    if (eventTypeCounts.isNotEmpty) {
      return '${eventTypeCounts.first.type} is your most requested event type — keep related decor in stock.';
    }
    return 'Closed deals outweigh ongoing ones — a good time to focus on new enquiries and portfolio visibility.';
  }
}
