import 'supabase_client.dart';

class ContactEnquiryService {
  final supabase = SupabaseClientManager.client;

  // wireframe 9 - Ongoing requests for booking
  Future<List<dynamic>> getEnquiriesForOrder(String orderId) async {
    return await supabase
      .from('Contact_Enquiry')
      .select()
      .eq('Order_id', orderId)
      .order('Enquiry_id', ascending: false);
  }

  Future<void> createEnquiry(String username, String orderId, String message) async {
    await supabase.from('Contact_Enquiry').insert({
      'Username': username,
      'Order_id': orderId,
      'Message': message,
    });
  }

  // Owner replying to client
  Future<void> replyEnquiry(String enquiryId, String response) async {
    await supabase.from('Contact_Enquiry').update({
      'Response': response,
    }).eq('Enquiry_id', enquiryId);
  }
}