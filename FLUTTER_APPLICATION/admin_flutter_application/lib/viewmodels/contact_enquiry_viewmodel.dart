import 'package:flutter/material.dart';
import '../services/contact_enquiry_service.dart';
import '../models/contact_enquiry.dart';

class ContactEnquiryViewModel extends ChangeNotifier {
  final _service = ContactEnquiryService();
  List<Contact_Enquiry> enquiries = [];
  bool loading = false;

  Future<void> loadForOrder(String orderId) async {
    loading = true; notifyListeners();
    final data = await _service.getEnquiriesForOrder(orderId);
    enquiries = data.map((e) => Contact_Enquiry(
      enquiryId: e['Enquiry_id'].toString(),
      username: e['Username'] ?? '',
      orderId: e['Order_id'].toString(),
      message: e['Message'] ?? '',
      response: e['Response'] ?? '',
    )).toList();
    loading = false; notifyListeners();
  }

  Future<void> sendMessage(String username, String orderId, String message) async {
    await _service.createEnquiry(username, orderId, message);
    await loadForOrder(orderId);
  }

  Future<void> reply(String enquiryId, String orderId, String response) async {
    await _service.replyEnquiry(enquiryId, response);
    await loadForOrder(orderId);
  }
}