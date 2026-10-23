import 'supabase_client.dart';

class AnalyticsService {
  final supabase = SupabaseClientManager.client;

  /// Deals still in progress: not yet completed, declined, or cancelled.
  Future<int> getOngoingDealsCount() async {
    final data = await supabase
        .from('orders')
        .select('id')
        .inFilter('status', ['pending', 'awaiting_deposit', 'in_preparation', 'setup']);
    return (data as List).length;
  }

  /// Deals that are finished one way or another.
  Future<int> getPastDealsCount() async {
    final data = await supabase
        .from('orders')
        .select('id')
        .inFilter('status', ['completed', 'declined', 'cancelled']);
    return (data as List).length;
  }

  /// Deal counts per month for the last [months] months, oldest first —
  /// used to draw the bar chart.
  Future<List<int>> getMonthlyDealCounts({int months = 10}) async {
    final since = DateTime.now().subtract(Duration(days: months * 31));
    final data = await supabase
        .from('orders')
        .select('created_at')
        .gte('created_at', since.toIso8601String());

    final counts = List<int>.filled(months, 0);
    final now = DateTime.now();
    for (final row in (data as List)) {
      final createdAt = DateTime.parse(row['created_at'] as String);
      final diffMonths = (now.year - createdAt.year) * 12 + (now.month - createdAt.month);
      final index = months - 1 - diffMonths;
      if (index >= 0 && index < months) counts[index]++;
    }
    return counts;
  }

  /// Confirmed revenue — summed from quotations.final_total where the
  /// quotation itself has been confirmed (final_total is only set once
  /// confirmed, per your schema).
  Future<double> getTotalRevenue() async {
    final data = await supabase
        .from('quotations')
        .select('final_total')
        .eq('status', 'confirmed');
    double sum = 0;
    for (final row in data as List) {
      sum += (row['final_total'] ?? 0).toDouble();
    }
    return sum;
  }
}