import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserLoginViewModel extends ChangeNotifier {
  bool loading = false;
  String? errorMessage;
  String? role;

  Future<bool> login(String email, String password) async {
    loading = true; errorMessage = null; notifyListeners();
    try {
      final auth = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      final uid = auth.user!.id;
      
      final profile = await Supabase.instance.client.from('profiles').select().eq('id', uid).single();
      
      if (profile['account_status'] == 'suspended') {
        errorMessage = 'Account suspended';
        await Supabase.instance.client.auth.signOut();
        loading = false; notifyListeners();
        return false;
      }
      
      role = profile['role']; // 'owner' or 'customer'
      loading = false; notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      loading = false; notifyListeners();
      return false;
    }
  }
}