import 'supabase_client.dart';

class MonthlyDealCount {
  final String label;
  final int count;
  const MonthlyDealCount({required this.label, required this.count});
}

class EventTypeCount {
  final String type;
  final int count;
  const EventTypeCount({required this.type, required this.count});
}

class AnalyticsSnapshot {
  final int ongoingDeals;
  final int pastDeals;
  final int uniqueClients;
  final double confirmedRevenue;
  final List<MonthlyDealCount> monthlyDealCounts;
  final List<EventTypeCount> eventTypeCounts;

  const AnalyticsSnapshot({
    required this.ongoingDeals,
    required this.pastDeals,
    required this.uniqueClients,
    required this.confirmedRevenue,
    required this.monthlyDealCounts,
    required this.eventTypeCounts,
  });
}

class AnalyticsService {
  final supabase = SupabaseClientManager.client;

  static const _ongoing = [
    'request_sent',
    'in_contact',
    'quotation_approved',
    'order_confirmed',
    'deposit_received',
    'preparations_begin',
  ];
  static const _past = ['completed', 'declined', 'cancelled'];
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  Future<AnalyticsSnapshot> loadSnapshot({int months = 10}) async {
    final allOrders = await supabase
        .from('orders')
        .select('id, status, event_type, customer_id, created_at');

    final quotations = await supabase
        .from('quotations')
        .select('final_total, estimated_total, status')
        .eq('status', 'confirmed');

    int ongoing = 0;
    int past = 0;
    final clients = <String>{};
    final typeCounts = <String, int>{};

    for (final row in allOrders as List) {
      final status = (row['status'] as String?) ?? 'pending';
      if (_ongoing.contains(status)) ongoing++;
      if (_past.contains(status)) past++;
      final customerId = row['customer_id'] as String?;
      if (customerId != null) clients.add(customerId);
      final type = (row['event_type'] as String?)?.trim();
      if (type != null && type.isNotEmpty) {
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }
    }

    double revenue = 0;
    for (final row in quotations as List) {
      final value = row['final_total'] ?? row['estimated_total'] ?? 0;
      revenue += value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    }

    final counts = List<int>.filled(months, 0);
    final now = DateTime.now();
    for (final row in allOrders as List) {
      final createdRaw = row['created_at'] as String?;
      if (createdRaw == null) continue;
      final createdAt = DateTime.parse(createdRaw);
      final diffMonths = (now.year - createdAt.year) * 12 + (now.month - createdAt.month);
      final index = months - 1 - diffMonths;
      if (index >= 0 && index < months) counts[index]++;
    }

    final monthly = List<MonthlyDealCount>.generate(months, (i) {
      final date = DateTime(now.year, now.month - (months - 1 - i));
      return MonthlyDealCount(label: _monthLabels[date.month - 1], count: counts[i]);
    });

    final eventTypes = typeCounts.entries
        .map((e) => EventTypeCount(type: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return AnalyticsSnapshot(
      ongoingDeals: ongoing,
      pastDeals: past,
      uniqueClients: clients.length,
      confirmedRevenue: revenue,
      monthlyDealCounts: monthly,
      eventTypeCounts: eventTypes.take(6).toList(),
    );
  }
}
