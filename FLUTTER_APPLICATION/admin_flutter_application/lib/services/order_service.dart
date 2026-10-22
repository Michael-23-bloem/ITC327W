import 'supabase_client.dart';

class OrderService {
  final supabase = SupabaseClientManager.client;

  // ------------------------------------------------------------------
  // WIREFRAME 4 - Quotation requests (pending orders)
  // Old: from('Order').eq('Status','Quotation')
  // New: from('orders').eq('status','pending') + join profiles for email
  // ------------------------------------------------------------------
  Future<List<dynamic>> getQuotationRequests() async {
    return await supabase
        .from('orders')
        .select('*, profiles(email, first_name, last_name)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
  }

  // ------------------------------------------------------------------
  // WIREFRAME 8 - Bookings - Past bookings (all non-pending)
  // ------------------------------------------------------------------
  Future<List<dynamic>> getBookings() async {
    return await supabase
        .from('orders')
        .select('*, profiles(email, first_name, last_name)')
        .neq('status', 'pending')
        .order('event_date', ascending: false);
  }

  // ------------------------------------------------------------------
  // WIREFRAME 5 - Requested items + Customer Details + Event Overview
  // Old: select User(Username...)
  // New: select profiles + order_items + decor_products
  // ------------------------------------------------------------------
  Future<dynamic> getOrder(String orderId) async {
    return await supabase
        .from('orders')
        .select('''
          *,
          profiles(email, first_name, last_name, phone_number),
          order_items(
            quantity,
            decor_products(name, price, image_url)
          ),
          quotations(*)
        ''')
        .eq('id', orderId)
        .single();
  }

  // ------------------------------------------------------------------
  // WIREFRAME 6 - Edit quotation Save
  // Old: updated Order table directly
  // New: quotations are in separate table `quotations`
  // ------------------------------------------------------------------
  Future<void> editQuotation(String orderId, double total, double transport, double service) async {
    // First get latest quotation for this order
    final existing = await supabase
        .from('quotations')
        .select('id')
        .eq('order_id', orderId)
        .order('version', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      // Update existing quotation
      await supabase.from('quotations').update({
        'estimated_total': total,
        'transportation_fee': transport,
        'service_fee': service,
      }).eq('id', existing['id']);
    } else {
      // Create first quotation
      await supabase.from('quotations').insert({
        'order_id': orderId,
        'estimated_total': total,
        'transportation_fee': transport,
        'service_fee': service,
        'status': 'sent_back',
      });
    }

    // Also update order status to in_contact
    await supabase.from('orders').update({'status': 'in_contact'}).eq('id', orderId);
  }

  // ------------------------------------------------------------------
  // WIREFRAME 7 - Validate EFT Payment -> converts Quotation to Booking
  // Old: Order.Status = Confirmed
  // New: deposits.status = received + orders.status = confirmed
  // ------------------------------------------------------------------
  Future<void> validateEftAndConvert(String orderId) async {
    // 1. Mark deposit as received
    final quotes = await supabase.from('quotations').select('id').eq('order_id', orderId);
    if (quotes.isNotEmpty) {
      final qId = quotes.first['id'];
      await supabase.from('deposits').update({'status': 'received'}).eq('quotation_id', qId);
    }

    // 2. Confirm order
    await supabase.from('orders').update({'status': 'confirmed'}).eq('id', orderId);
  }

  // ------------------------------------------------------------------
  // WIREFRAME 10 - Update progress Save + Add note
  // ------------------------------------------------------------------
  Future<void> updateProgress(String orderId, String status, String note) async {
    await supabase.from('orders').update({
      'status': status,
      'notes': note,
    }).eq('id', orderId);
  }
}


/*import 'supabase_client.dart';

class OrderService {
  final supabase = SupabaseClientManager.client;

  // wireframe 4 - Quotation requests
  Future<List<dynamic>> getQuotationRequests() async {
    return await supabase.from('Order').select().eq('Status', 'Quotation').order('Order_id', ascending: false);
  }

  // wireframe 8 - Bookings - Past bookings
  Future<List<dynamic>> getBookings() async {
    return await supabase.from('Order').select().neq('Status', 'Quotation').order('Date_to_deliver', ascending: false);
  }

  // wireframe 5 - Requested items + Customer Details + Event Overview
  Future<dynamic> getOrder(String orderId) async {
    return await supabase.from('Order').select('*, User(Username, Display_name, Email, Phone)').eq('Order_id', orderId).single();
  }

  // wireframe 6 - Edit quotation Save
  Future<void> editQuotation(String orderId, double total, double transport, double service) async {
    await supabase.from('Order').update({
      'Total_price': total,
      'Transport_fee': transport,
      'Service_fee': service,
    }).eq('Order_id', orderId);
  }

  // wireframe 7 - Validate EFT Payment -> converts Quotation to Booking
  Future<void> validateEftAndConvert(String orderId) async {
    await supabase.from('Order').update({
      'Status': 'Confirmed',
      'Payment_status': 'Paid',
    }).eq('Order_id', orderId);
  }

  // wireframe 10 - Update progress Save + Add note
  Future<void> updateProgress(String orderId, String status, String note) async {
    await supabase.from('Order').update({
      'Status': status,
      'Notes': note,
    }).eq('Order_id', orderId);
  }
}*/