import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/portfolio_viewmodel.dart';
import '../../models/portfolio.dart';
import 'portfolio_edit_view.dart';

class PortfolioListView extends StatefulWidget {
  const PortfolioListView({super.key});

  @override
  State<PortfolioListView> createState() => _PortfolioListViewState();
}

class _PortfolioListViewState extends State<PortfolioListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PortfolioViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PortfolioViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/portfolio/upload'),
        child: const Icon(Icons.add),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: vm.events.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _showPortfolioSheet(context, vm.events[i]),
                child: Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          vm.events[i].imageUrl,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                        ),
                      ),
                      Text(vm.events[i].name ?? 'Untitled'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showPortfolioSheet(BuildContext context, Portfolio p) {
    final vm = context.read<PortfolioViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: vm.loadDetail(p.id),
        builder: (ctx, snapshot) {
          final images = [p.imageUrl, ...(snapshot.data?['images'] as List<String>? ?? [])];
          final items = snapshot.data?['items'] as List<String>? ?? [];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : PageView(
                            children: images
                                .map((url) => ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(url, fit: BoxFit.cover),
                                    ))
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${images.length} photo${images.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (p.category != null)
                    Text(p.category!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (p.price != null)
                    Text('R${p.price!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                  if (p.description != null) ...[
                    const SizedBox(height: 8),
                    Text(p.description!),
                  ],
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Items used', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((name) => Chip(label: Text(name))).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx); // close the sheet first
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PortfolioEditView(portfolio: p)),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Delete this item?'),
                            content: const Text('This will permanently remove it and its photos.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await vm.deletePortfolio(p.id);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Delete failed: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}