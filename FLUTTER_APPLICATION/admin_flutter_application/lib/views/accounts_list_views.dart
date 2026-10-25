import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../models/user.dart' as app_models; // adjust path to match reality

class AccountListView extends StatefulWidget {
  const AccountListView({super.key});

  @override
  State<AccountListView> createState() => _AccountListViewState();
}

class _AccountListViewState extends State<AccountListView> {
  bool showSuspended = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UserViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    final List<app_models.User> filtered = showSuspended
        ? vm.users
        : vm.users.where((u) => u.accountStatus.toLowerCase() != 'suspended').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SwitchListTile(
                  title: const Text('Show Suspended'),
                  value: showSuspended,
                  onChanged: (v) => setState(() => showSuspended = v),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final app_models.User u = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              u.firstName != null && u.firstName!.isNotEmpty
                                  ? u.firstName![0].toUpperCase()
                                  : u.email[0].toUpperCase(),
                            ),
                          ),
                          title: Text(u.fullName.isEmpty ? u.email : u.fullName),
                          subtitle: Text(u.email),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: u.accountStatus == 'suspended' ? Colors.red.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              u.accountStatus,
                              style: TextStyle(
                                color: u.accountStatus == 'suspended' ? Colors.red : Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () => context.push('/accounts/${u.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}