class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final String role; // 'customer' or 'owner'
  final String accountStatus; // 'active' or 'suspended'
  final DateTime createdAt;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
  });

  String get fullName {
    if (firstName == null && lastName == null) return email;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      role: json['role'] ?? 'customer',
      accountStatus: json['account_status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'account_status': accountStatus,
    };
  }
}