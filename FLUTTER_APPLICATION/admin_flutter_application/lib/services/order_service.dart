import 'supabase_client.dart';
import '../models/quotation.dart';
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
        .inFilter('status', [ 'deposit_received', 'preparations_begin'])
        .order('event_date', ascending: true);
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
  /*Future<void> editQuotation(String orderId, double total, double transport, double service) async {
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
  }*/

  // ------------------------------------------------------------------
  // WIREFRAME 7 - Validate EFT Payment -> converts Quotation to Booking
  // Old: Order.Status = Confirmed
  // New: deposits.status = received + orders.status = confirmed
  // ------------------------------------------------------------------
  
   // Load the latest quotation for the Edit Quotation page.
   // Retrieve the latest quotation version, including its JSONB items.
  Future<Map<String, dynamic>?> getLatestQuotation(
    String orderId,
  ) async {
    final data = await supabase
        .from('quotations')
        .select()
        .eq('order_id', orderId)
        .order('version', ascending: false)
        .limit(1)
        .maybeSingle();

    return data;
  }
  void testQuotationItem() {
  final item = QuotationItem(
    productName: 'Test decoration',
    quantity: 2,
    unitPrice: 100,
  );

  print(item.totalPrice);
}
  // Save a revision as a NEW quotation version.
  
  // Save a new quotation version with its items and financial summary.
  Future<Map<String, dynamic>> editQuotation(
    String orderId,
    List<QuotationItem> items,
    double transport,
    double service,
  ) async {
    if (transport < 0 || service < 0) {
      throw Exception('Quotation fees cannot be negative.');
    }

    // Validate quotation items.
    for (final item in items) {
      if (item.quantity <= 0 || item.unitPrice < 0) {
        throw Exception('Invalid quotation item quantity or price.');
      }
    }

    // Calculate the item subtotal.
    final itemsSubtotal = items.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    // Calculate the complete estimated quotation total.
    final total = itemsSubtotal + transport + service;

    // Retrieve the previous quotation version.
    final latest = await getLatestQuotation(orderId);

    final nextVersion = latest == null
        ? 1
        : (latest['version'] as num).toInt() + 1;

    // Save a new quotation version.
    final savedQuotation = await supabase
        .from('quotations')
        .insert({
          'order_id': orderId,
          'version': nextVersion,
          'status': 'pending',
          'estimated_total': total,
          'transportation_fee': transport,
          'service_fee': service,

          // Save the items inside the JSONB column.
          'quotation_items': items
              .map((item) => item.toJson())
              .toList(),
        })
        .select()
        .single();

    return savedQuotation;
  }

  /*Future<void> editQuotation(
    String orderId,
    double total,
    double transport,
    double service,
  ) async {
    if (total < 0 || transport < 0 || service < 0) {
      throw Exception('Quotation amounts cannot be negative.');
    }

    // Get the latest version so we can increment it.
    final latest = await getLatestQuotation(orderId);

    final nextVersion = latest == null
        ? 1
        : ((latest['version'] as num).toInt() + 1);

    // Insert instead of updating: the previous quotation remains unchanged.
    await supabase.from('quotations').insert({
      'order_id': orderId,
      'version': nextVersion,
      'status': 'pending',
      'estimated_total': total,
      'transportation_fee': transport,
      'service_fee': service,
    });

    // Do not reset the order's status here.
    // The existing order may already be confirmed or in preparation.
  }*/
/*Future<Map<String, dynamic>?> getLatestQuotation(
    String orderId) async {
  final data = await supabase
      .from('quotations')
      .select(
        'id, order_id, estimated_total, transportation_fee, service_fee, status, version',
      )
      .eq('order_id', orderId)
      .order('version', ascending: false)
      .limit(1)
      .maybeSingle();

  return data;
}*/



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

  Future<void> confirmQuotation(String orderId) async {
    await supabase.from('orders').update({
      'status': 'quotation_approved',
    }).eq('id', orderId);
  }

  Future<void> markInContact(String orderId) async {
    await supabase.from('orders').update({
      'status': 'in_contact',
    }).eq('id', orderId);
  }
}
