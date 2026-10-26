import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/portfolio_viewmodel.dart';

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
          : vm.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.error!),
                      const SizedBox(height: 12),
                      TextButton(onPressed: vm.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : vm.events.isEmpty
                  ? const Center(child: Text('No portfolio events yet'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: vm.events.length,
                      itemBuilder: (_, i) {
                        final event = vm.events[i];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Expanded(
                                child: event.imageUrl.isEmpty
                                    ? const Center(child: Icon(Icons.image))
                                    : Image.network(
                                        event.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(Icons.image),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  event.name?.isNotEmpty == true ? event.name! : 'Untitled',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}