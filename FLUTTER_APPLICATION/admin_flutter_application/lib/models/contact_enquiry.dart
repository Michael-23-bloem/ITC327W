class Contact_Enquiry {
  String enquiryId; // Enquiry_id PK
  String username; // Username FK
  String orderId; // Order_id FK
  String message; // Message - Additional notes
  String response; // Response

  Contact_Enquiry({
    required this.enquiryId,
    required this.username,
    required this.orderId,
    required this.message,
    required this.response,
  });
}