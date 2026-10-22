import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/analytics_viewmodel.dart';

class ClientAnalyticsView extends StatefulWidget {
  const ClientAnalyticsView({super.key});

  @override
  State<ClientAnalyticsView> createState() => _ClientAnalyticsViewState();
}

class _ClientAnalyticsViewState extends State<ClientAnalyticsView> {
  late final AnalyticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AnalyticsViewModel();
    _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AnalyticsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Analytics')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(label: 'Total Bookings', value: '${vm.totalBookings}'),
                _StatCard(label: 'Pending Quotations', value: '${vm.pendingQuotations}'),
                _StatCard(label: 'Completed Bookings', value: '${vm.completedBookings}'),
                _StatCard(
                  label: 'Total Revenue',
                  value: 'R${vm.totalRevenue.toStringAsFixed(2)}',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}