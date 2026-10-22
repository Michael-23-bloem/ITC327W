import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final _db = Supabase.instance.client;
  Future<List<dynamic>> getUsers() async => await _db.from('profiles').select();
  Future<dynamic> getUserDetail(String id) async => await _db.from('profiles').select().eq('id', id).single();
  Future<void> suspendUser(String id) async => await _db.from('profiles').update({'account_status': 'suspended'}).eq('id', id);
  Future<void> reactivateUser(String id) async => await _db.from('profiles').update({'account_status': 'active'}).eq('id', id);
  Future<void> deleteUser(String id) async => await _db.from('profiles').delete().eq('id', id);
}





/*import 'supabase_client.dart';

class UserService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getUsers() async {
    return await supabase.from('User').select().order('Username');
  }

  Future<dynamic> getUserDetail(String username) async {
    return await supabase.from('User').select().eq('Username', username).single();
  }

  // wireframe 14 - Show Suspended filter + Suspend button
  Future<void> suspendUser(String username) async {
    await supabase.from('User').update({'Status': 'Suspended'}).eq('Username', username);
  }

  Future<void> reactivateUser(String username) async {
    await supabase.from('User').update({'Status': 'Active'}).eq('Username', username);
  }

  Future<void> deleteUser(String username) async {
    await supabase.from('User').delete().eq('Username', username);
  }
}*/