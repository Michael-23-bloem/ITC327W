import 'package:flutter/material.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onSuspend;
  final VoidCallback? onReactivate;
  final VoidCallback? onDelete;

  const UserCard({super.key, required this.user, this.onSuspend, this.onReactivate, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isSuspended = user.accountStatus == 'suspended';
    final isOwner = user.role == 'owner';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOwner ? Colors.purple : Colors.blue,
          child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : user.email[0].toUpperCase(),
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Row(
              children: [
                Chip(label: Text(user.role, style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                const SizedBox(width: 4),
                Chip(
                  label: Text(user.accountStatus, style: const TextStyle(fontSize: 10)),
                  backgroundColor: isSuspended ? Colors.red[100] : Colors.green[100],
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (c) => [
            if (!isSuspended) PopupMenuItem(value: 'suspend', child: const Text('Suspend')),
            if (isSuspended) PopupMenuItem(value: 'reactivate', child: const Text('Reactivate')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (v) {
            if (v == 'suspend') onSuspend?.call();
            if (v == 'reactivate') onReactivate?.call();
            if (v == 'delete') onDelete?.call();
          },
        ),
      ),
    );
  }
}