import 'supabase_client.dart';

class AnalyticsService {
  final supabase = SupabaseClientManager.client;

  Future<int> getTotalBookings() async {
    final data = await supabase.from('Order').select('Order_id').neq('Status', 'Quotation');
    return (data as List).length;
  }

  Future<int> getPendingQuotations() async {
    final data = await supabase.from('Order').select('Order_id').eq('Status', 'Quotation');
    return (data as List).length;
  }

  Future<double> getTotalRevenue() async {
    final data = await supabase.from('Order').select('Total_price').eq('Payment_status', 'Paid');
    double sum = 0;
    for (var e in data as List) {
      sum += (e['Total_price'] ?? 0).toDouble();
    }
    return sum;
  }

  Future<int> getCompletedBookings() async {
    final data = await supabase.from('Order').select('Order_id').eq('Status', 'Completed');
    return (data as List).length;
  }
}