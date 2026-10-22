// views/account/account_detail_view.dart - FIXED FOR NEW SQL (profiles table)
// wireframe 4 + 14 Delete with confirmation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';

class AccountDetailView extends StatefulWidget {
  final String userId; // OLD: username, NEW: id (uuid)
  const AccountDetailView({super.key, required this.userId});

  @override
  State<AccountDetailView> createState() => _AccountDetailViewState();
}

class _AccountDetailViewState extends State<AccountDetailView> {
  @override
  void initState() {
    super.initState();
    // NEW: get by id, not username
    Future.microtask(() => context.read<UserViewModel>().getDetail(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final user = vm.selectedUser;

    if (vm.loading || user == null) {
      return Scaffold(appBar: AppBar(title: const Text('Account Details')), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(user.fullName.isNotEmpty ? user.fullName : user.email)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // FIXED: old fields -> new fields
          Text('Name: ${user.fullName}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Email: ${user.email}'),
          Text('Phone: ${user.phoneNumber ?? 'No phone'}'),
          Text('Role: ${user.role}'),
          Text('Status: ${user.accountStatus}'),
          const SizedBox(height: 24),
          Row(children: [
            ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Suspend ${user.fullName}?'),
                    content: Text('User will not be able to login. Email: ${user.email}'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Suspend')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await vm.suspend(user.id); // NEW: use id not username
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Suspend'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                await vm.reactivate(user.id);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Reactivate')),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Delete ${user.fullName}?'),
                    content: const Text('This cannot be undone. Profile + auth user will be removed.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await vm.delete(user.id);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Delete'),
            ),
          ]),
        ]),
      ),
    );
  }
}