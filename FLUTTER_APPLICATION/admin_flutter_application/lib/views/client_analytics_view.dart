import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/analytics_service.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../widgets/akea_ui.dart';

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
          return AkeaPage(
            child: vm.loading && vm.monthlyDealCounts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: vm.load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                      children: [
                        const AkeaPageHeader(
                          title: 'Client analytics',
                          subtitle: 'Overview of deals and activity',
                        ),
                        if (vm.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(vm.error!, style: const TextStyle(color: Colors.redAccent)),
                          ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth >= 900 ? 3 : 1;
                            return GridView.count(
                              crossAxisCount: cols,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 2.4,
                              children: [
                                _StatCard(
                                  label: 'Ongoing deals',
                                  value: '${vm.ongoingDeals}',
                                  icon: Icons.trending_up,
                                ),
                                _StatCard(
                                  label: 'Past deals',
                                  value: '${vm.pastDeals}',
                                  icon: Icons.check_circle_outline,
                                ),
                                _StatCard(
                                  label: 'Awaiting decision',
                                  value: '${vm.awaitingDecision}',
                                  icon: Icons.description_outlined,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _ChartCard(counts: vm.monthlyDealCounts),
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
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AkeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(color: AkeaColors.muted)),
              const Spacer(),
              CircleAvatar(
                radius: 16,
                backgroundColor: AkeaColors.cream,
                child: Icon(icon, size: 16, color: AkeaColors.purple),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AkeaColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.counts});
  final List<MonthlyDealCount> counts;

  @override
  Widget build(BuildContext context) {
    final maxVal = counts.isEmpty
        ? 1
        : counts.map((c) => c.count).fold<int>(1, (a, b) => a > b ? a : b);

    return AkeaCard(
      child: SizedBox(
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Deals per month', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                const Text(
                  'Live booking data',
                  style: TextStyle(color: AkeaColors.muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: counts.every((c) => c.count == 0)
                  ? const Center(child: Text('No data yet', style: TextStyle(color: AkeaColors.muted)))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < counts.length; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${counts[i].count}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: (counts[i].count / maxVal).clamp(0.08, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: i == counts.length - 1
                                                ? AkeaColors.gold
                                                : AkeaColors.purple,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    counts[i].label,
                                    style: const TextStyle(fontSize: 12, color: AkeaColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
