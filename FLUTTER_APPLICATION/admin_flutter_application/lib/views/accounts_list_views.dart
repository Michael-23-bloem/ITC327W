import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as app_models;
import '../theme/akea_theme.dart';
import '../viewmodels/user_viewmodel.dart';
import '../widgets/akea_ui.dart';

class AccountListView extends StatefulWidget {
  const AccountListView({super.key, this.userId});
  final String? userId;

  @override
  State<AccountListView> createState() => _AccountListViewState();
}

class _AccountListViewState extends State<AccountListView> {
  String _query = '';
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserViewModel>().load().then((_) {
          if (!mounted) return;
          final vm = context.read<UserViewModel>();
          final id = _selectedId ?? (vm.users.isNotEmpty ? vm.users.first.id : null);
          if (id != null) {
            setState(() => _selectedId = id);
            vm.getDetail(id);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final filtered = vm.users.where((u) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return u.fullName.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();
    final selected = vm.selectedUser?.id == _selectedId
        ? vm.selectedUser
        : filtered.cast<app_models.User?>().firstWhere(
            (u) => u!.id == _selectedId,
            orElse: () => filtered.isEmpty ? null : filtered.first,
          );

          
      return Scaffold(
  appBar: AppBar(
    backgroundColor: AkeaColors.card,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back to Dashboard',
      onPressed: () => context.go('/dashboard'),
    ),
    title: const AkeaPageHeader(
            title: 'Client accounts',
            subtitle: 'Website accounts',
  ),
  toolbarHeight: 90,
    
    
  ),
    body:  AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          /*const AkeaPageHeader(
            title: 'Client accounts',
            subtitle: 'Website accounts',
          ),*/
          if (vm.loading && vm.users.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 900;
                final list = Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search clients',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No client accounts match this search.',
                          style: TextStyle(color: AkeaColors.muted),
                        ),
                      ),
                    for (final u in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: u.id == selected?.id ? const Color(0xFFF4E7C8) : AkeaColors.card,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() => _selectedId = u.id);
                              vm.getDetail(u.id);
                              context.go('/accounts/${u.id}');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: u.id == selected?.id
                                    ? Border.all(color: AkeaColors.goldSoft)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      u.fullName.isEmpty ? u.email : u.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  AkeaStatusChip.forStatus(u.accountStatus),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
                final detail = selected == null
                    ? const AkeaCard(child: Text('Select a client account.'))
                    : _AccountDetailCard(user: selected, vm: vm);
                if (stacked) {
                  return Column(children: [list, const SizedBox(height: 16), detail]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 300, child: list),
                    const SizedBox(width: 20),
                    Expanded(child: detail),
                  ],
                );
              },
            ),
        ],
      ),
    ));
  }
}

class _AccountDetailCard extends StatelessWidget {
  const _AccountDetailCard({required this.user, required this.vm});
  final app_models.User user;
  final UserViewModel vm;

  @override
  Widget build(BuildContext context) {
    return AkeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.fullName.isEmpty ? user.email : user.fullName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              AkeaStatusChip.forStatus(user.accountStatus),
            ],
          ),
          const SizedBox(height: 22),
          const AkeaFieldLabel('Email'),
          InputDecorator(
            decoration: const InputDecoration(),
            child: Text(user.email),
          ),
          const SizedBox(height: 16),
          const AkeaFieldLabel('Phone'),
          InputDecorator(
            decoration: const InputDecoration(),
            child: Text(user.phoneNumber ?? '—'),
          ),
          const Divider(height: 36, color: AkeaColors.border),
          const AkeaFieldLabel('Actions'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AkeaButton(
                label: 'Suspend account',
                style: AkeaButtonStyle.outline,
                onPressed: () async {
                  final ok = await showDialog<bool>(
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
                  if (ok == true) await vm.suspend(user.id);
                },
              ),
              AkeaButton(
                label: 'Reactivate',
                onPressed: () => vm.reactivate(user.id),
              ),
              AkeaButton(
                label: 'Delete account',
                style: AkeaButtonStyle.dangerSoft,
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Delete ${user.fullName}?'),
                      content: const Text('This cannot be undone. Profile will be removed.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await vm.delete(user.id);
                    if (context.mounted) context.go('/accounts');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
