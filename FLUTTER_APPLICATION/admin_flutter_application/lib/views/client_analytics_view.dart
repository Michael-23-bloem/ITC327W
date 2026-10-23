import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
          return Scaffold(
            backgroundColor: const Color(0xFFBDBAB5),
            body: SafeArea(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      children: [
                        const Text(
                          'Client analytics',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        _StatCard(label: 'Ongoing deals', value: '${vm.ongoingDeals}'),
                        const SizedBox(height: 16),
                        _StatCard(label: 'Past Deals', value: '${vm.pastDeals}'),
                        const SizedBox(height: 16),
                        _ChartCard(counts: vm.monthlyDealCounts),
                        const SizedBox(height: 14),
                        _AiTipCard(tip: vm.aiTip),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/bookings'),
                            child: const Text(
                              'Calendar',
                              style: TextStyle(color: Color(0xFFB5651D), fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<int> counts;
  const _ChartCard({required this.counts});

  @override
  Widget build(BuildContext context) {
    final maxVal = counts.isEmpty ? 1 : (counts.reduce((a, b) => a > b ? a : b)).clamp(1, 1 << 30);
    return Container(
      width: double.infinity,
      height: 210,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: counts.isEmpty
          ? const Center(child: Text('No data yet', style: TextStyle(color: Colors.black54)))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: counts.map((c) {
                final heightFraction = c / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FractionallySizedBox(
                      heightFactor: heightFraction.clamp(0.05, 1.0),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFFA9A9A9), borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

/// Small "AI contribution" card — surfaces a quick tip/strategy suggestion
/// generated from the chart data (see AnalyticsViewModel.aiTip).
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