import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final _service = AnalyticsService();

  int ongoingDeals = 0;
  int pastDeals = 0;
  List<int> monthlyDealCounts = [];
  bool loading = false;

  String get aiTip => _generateTip();

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      ongoingDeals = await _service.getOngoingDealsCount();
      pastDeals = await _service.getPastDealsCount();
      monthlyDealCounts = await _service.getMonthlyDealCounts();
    } catch (e) {
      debugPrint('Analytics load failed: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Simple rule-based "AI" tip — no external API call, just reads the
  // numbers we already have and picks the most relevant message.
  String _generateTip() {
    if (monthlyDealCounts.isEmpty) {
      return 'Not enough data yet to generate a tip — check back once you have a few bookings.';
    }

    final total = ongoingDeals + pastDeals;
    if (total == 0) {
      return 'No deals recorded yet. Share your portfolio to start attracting enquiries.';
    }

    final recent = monthlyDealCounts.length >= 2
        ? monthlyDealCounts[monthlyDealCounts.length - 1]
        : 0;
    final prior = monthlyDealCounts.length >= 2
        ? monthlyDealCounts[monthlyDealCounts.length - 2]
        : 0;

    if (recent > prior) {
      return 'Deals are trending up this month — consider following up on open quotations '
          'quickly while demand is high.';
    }
    if (recent < prior && prior > 0) {
      return 'Deals dipped compared to last month. A promo on past client favourites could '
          'help bring bookings back up.';
    }
    if (ongoingDeals > pastDeals) {
      return 'You have more ongoing deals than closed ones — prioritise following up on '
          'pending quotations to convert them faster.';
    }
    return 'Your closed deals outweigh ongoing ones — good time to focus on new enquiries '
        'and portfolio visibility.';
  }
}