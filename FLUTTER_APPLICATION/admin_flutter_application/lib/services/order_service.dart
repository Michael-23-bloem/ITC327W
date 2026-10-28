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
        .inFilter('status', ['request_sent', 'in_contact', 'quotation_approved'])
        .order('created_at', ascending: false);
  }

  // ------------------------------------------------------------------
  // WIREFRAME 8 - Bookings - Past bookings (all non-pending)
  // ------------------------------------------------------------------
  Future<List<dynamic>> getBookings() async {
    return await supabase
        .from('orders')
        .select('*, profiles(email, first_name, last_name)')
        .inFilter('status', ['order_confirmed', 'deposit_received', 'preparations_begin'])
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
  // 1. Get the authenticated owner.
  final owner = supabase.auth.currentUser;

  if (owner == null) {
    throw Exception('You must be logged in to validate a deposit.');
  }

  // 2. Fetch the latest quotation for this order.
  final quotation = await supabase
      .from('quotations')
      .select('id, status, estimated_total')
      .eq('order_id', orderId)
      .order('version', ascending: false)
      .limit(1)
      .maybeSingle();

  if (quotation == null) {
    throw Exception('No quotation exists for this order.');
  }

  if (quotation['status'] != 'confirmed') {
    throw Exception(
      'Only confirmed quotations can have deposits validated.',
    );
  }

  final total =
      (quotation['estimated_total'] as num?)?.toDouble() ?? 0.0;

  if (total <= 0) {
    throw Exception(
      'The quotation total must be greater than zero.',
    );
  }

  final quotationId = quotation['id'];

  // 3. Find the deposit awaiting validation.
  final deposit = await supabase
      .from('deposits')
      .select('id, amount, reference, status')
      .eq('quotation_id', quotationId)
      .eq('status', 'awaiting')
      .maybeSingle();

  if (deposit == null) {
    throw Exception(
      'No deposit awaiting validation was found.',
    );
  }

  final amount =
      (deposit['amount'] as num?)?.toDouble() ?? 0.0;

  if (amount <= 0) {
    throw Exception('The deposit amount must be greater than zero.');
  }

  // IMPORTANT:
  // The owner must first verify the EFT in the business bank account.

  // 4. Mark the deposit as received and record who confirmed it.
  final updatedDeposit = await supabase
      .from('deposits')
      .update({
        'status': 'received',
        'received_at': DateTime.now().toUtc().toIso8601String(),
        'confirmed_by': owner.id,
      })
      .eq('id', deposit['id'])
      .eq('status', 'awaiting')
      .select('id');

  if (updatedDeposit.isEmpty) {
    throw Exception(
      'The deposit may already have been processed. Refresh and check its status.',
    );
  }

  // 5. Update the order after the deposit update succeeds.
  final updatedOrder = await supabase
      .from('orders')
      .update({'status': 'deposit_received'})
      .eq('id', orderId)
      .select('id');

  if (updatedOrder.isEmpty) {
    throw Exception(
      'The deposit was updated, but the order could not be updated. '
      'Check the database before trying again.',
    );
  }
}


  /*Future<void> validateEftAndConvert(String orderId) async {
    // 1. Mark deposit as received
    final quotes = await supabase.from('quotations').select('id').eq('order_id', orderId);
    if (quotes.isNotEmpty) {
      final qId = quotes.first['id'];
      await supabase.from('deposits').update({'status': 'received'}).eq('quotation_id', qId);
    }

    // 2. Confirm order
    await supabase.from('orders').update({'status': 'deposit_received'}).eq('id', orderId);
  }
*/
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