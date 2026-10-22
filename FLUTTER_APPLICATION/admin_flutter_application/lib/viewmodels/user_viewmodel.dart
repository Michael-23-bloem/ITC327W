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
      await supabase.from('profiles').update({'account_status': 'suspended'}).eq('id', id);
      await load();
    } catch (e) {
      debugPrint('suspend error: $e');
    }
  }

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
}