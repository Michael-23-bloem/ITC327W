import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/analytics_service.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../widgets/akea_ui.dart';
import '../widgets/admin_shell.dart';

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
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AnalyticsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AkeaColors.bg,
            body: SafeArea(
              child: vm.loading && vm.monthlyDealCounts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        return RefreshIndicator(
                          onRefresh: vm.load,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 20, wide ? 32 : 20, 24),
                            children: [
                              AkeaPageHeader(
                                title: 'Client analytics',
                                subtitle: 'Deals, clients and confirmed revenue',
                                actions: [
                                  TextButton(
                                    onPressed: () => context.go('/bookings'),
                                    child: const Text(
                                      'Calendar',
                                      style: TextStyle(
                                        color: AkeaColors.plum,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (vm.error != null) ...[
                                const SizedBox(height: 12),
                                Text(vm.error!, style: const TextStyle(color: Colors.redAccent)),
                              ],
                              const SizedBox(height: 20),
                              if (wide)
                                _WideLayout(vm: vm)
                              else
                                _NarrowLayout(vm: vm),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.vm});
  final AnalyticsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatCard(label: 'Ongoing deals', value: '${vm.ongoingDeals}'),
        const SizedBox(height: 16),
        _StatCard(label: 'Past Deals', value: '${vm.pastDeals}'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _MiniStat(label: 'Clients', value: '${vm.uniqueClients}')),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat(label: 'Confirmed', value: _formatRand(vm.confirmedRevenue))),
          ],
        ),
        const SizedBox(height: 16),
        _ChartCard(counts: vm.monthlyDealCounts),
        const SizedBox(height: 14),
        _EventTypesCard(types: vm.eventTypeCounts),
        const SizedBox(height: 14),
        _AiTipCard(tip: vm.aiTip),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.vm});
  final AnalyticsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Ongoing deals', value: '${vm.ongoingDeals}')),
            const SizedBox(width: 16),
            Expanded(child: _StatCard(label: 'Past Deals', value: '${vm.pastDeals}')),
            const SizedBox(width: 16),
            Expanded(child: _MiniStat(label: 'Clients', value: '${vm.uniqueClients}')),
            const SizedBox(width: 16),
            Expanded(child: _MiniStat(label: 'Confirmed', value: _formatRand(vm.confirmedRevenue))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _ChartCard(counts: vm.monthlyDealCounts, height: 280)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _EventTypesCard(types: vm.eventTypeCounts),
                  const SizedBox(height: 16),
                  _AiTipCard(tip: vm.aiTip),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatRand(double value) {
  final abs = value.abs();
  if (abs >= 1000) {
    return 'R${(value / 1000).toStringAsFixed(1)}k';
  }
  return 'R${value.toStringAsFixed(0)}';
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<MonthlyDealCount> counts;
  final double height;
  const _ChartCard({required this.counts, this.height = 210});

  @override
  Widget build(BuildContext context) {
    final maxVal = counts.isEmpty
        ? 1
        : counts.map((c) => c.count).fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deals by month', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: counts.every((c) => c.count == 0)
                ? const Center(child: Text('No data yet', style: TextStyle(color: Colors.black54)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final month in counts)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: (month.count / maxVal).clamp(0.04, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFA9A9A9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(month.label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventTypesCard extends StatelessWidget {
  final List<EventTypeCount> types;
  const _EventTypesCard({required this.types});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Event types', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (types.isEmpty)
            const Text('No event types yet', style: TextStyle(color: Colors.black54))
          else
            for (final type in types)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(type.type)),
                    Text('${type.count}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _AiTipCard extends StatelessWidget {
  final String tip;
  const _AiTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3D6), Color(0xFFDCEBFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF5A7FBF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI tip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(tip, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: AkeaColors.card,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: AkeaColors.border),
  boxShadow: [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
  ],
);
