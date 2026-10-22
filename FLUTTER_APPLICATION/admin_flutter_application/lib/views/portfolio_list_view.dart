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
        onPressed: () => context.go('/portfolio/upload'),
        child: const Icon(Icons.add),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: vm.events.length,
              itemBuilder: (_, i) => Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        vm.events[i].imageUrl,
                        errorBuilder: (_, _, _) => const Icon(Icons.image),
                      ),
                    ),
                    Text(vm.events[i].name ?? 'Untitled'),
                  ],
                ),
              ),
            ),
    );
  }
}