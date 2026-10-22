class User_Authentication {
  String authenticationId; // Authentication_id PK
  String username; // Username FK
  String password; // Password

  User_Authentication({
    required this.authenticationId,
    required this.username,
    required this.password,
  });
}