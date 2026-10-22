import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseClientManager {
  static final client = Supabase.instance.client;
}
// IMPORTANT: Your ERD uses Capital letters "User", "Order"
// In Supabase if you created with quotes, call like: supabase.from('"User"')
// If you created without quotes, it becomes lowercase: supabase.from('User')
// I use lowercase below to avoid errors, rename if needed