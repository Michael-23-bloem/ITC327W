import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../services/user_service.dart';
import '../models/user.dart';

class UserViewModel extends ChangeNotifier {
  final _service = UserService();
  final supabase = Supabase.instance.client;
  
  List<User> users = [];
  User? selectedUser;
  bool loading = false;

  Future<void> load() async {
    loading = true; 
    notifyListeners();
    try {
      final data = await _service.getUsers();
      users = data.map((e) => User.fromJson(e)).toList();
    } catch (e) {
      debugPrint('load users error: $e');
    }
    loading = false; 
    notifyListeners();
  }

  Future<void> getDetail(String id) async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getUserDetail(id);
      selectedUser = User.fromJson(data);
    } catch (e) {
      debugPrint('getDetail error: $e');
    }
    loading = false;
    notifyListeners();
  }


  Future<void> suspend(String id) async {
  try {
    debugPrint('========== SUSPEND TEST ==========');
    debugPrint('CLIENT ID: $id');

    final response = await supabase
        .from('profiles')
        .update({'account_status': 'suspended'})
        .eq('id', id)
        .select();

    debugPrint('UPDATE RESPONSE: $response');

    if (response.isEmpty) {
      debugPrint('WARNING: No profile was updated!');
    } else {
      debugPrint('SUCCESS: Client account suspended!');
    }

    await load();

  } catch (e, stackTrace) {
    debugPrint('SUSPEND ERROR: $e');
    debugPrint('STACK TRACE: $stackTrace');
  }
}

  /*Future<void> suspend(String id) async {
    try {
      await supabase.from('profiles').update({'account_status': 'suspended'}).eq('id', id);
      await load();
    } catch (e) {
      debugPrint('suspend error: $e');
    }
  }*/

  Future<void> reactivate(String id) async {
    try {
      await supabase.from('profiles').update({'account_status': 'active'}).eq('id', id);
      await load();
    } catch (e) {
      debugPrint('reactivate error: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('profiles').delete().eq('id', id);
      await load();
    } catch (e) {
      debugPrint('delete error: $e');
    }
  }

  Future<void> testOwnerSession() async {
  final user = supabase.auth.currentUser;

  debugPrint('========== OWNER SESSION TEST ==========');
  debugPrint('AUTH USER ID: ${user?.id}');
  debugPrint('AUTH EMAIL: ${user?.email}');

  try {
    final result = await supabase.rpc('is_owner');

    debugPrint('IS OWNER: $result');
  } catch (e) {
    debugPrint('OWNER CHECK ERROR: $e');
  }

  debugPrint('=========================================');
}
}