
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/analytics_service.dart';
import '../theme/akea_theme.dart';
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
            appBar: AppBar(
              backgroundColor: AkeaColors.card,
              elevation: 0,
              toolbarHeight: 76,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AkeaColors.ink,
                ),
                tooltip: 'Back to Dashboard',
                onPressed: () => context.go('/dashboard'),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Client analytics',
                    style: TextStyle(
                      color: AkeaColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Deals, clients and confirmed revenue',
                    style: TextStyle(
                      color: AkeaColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.go('/bookings'),
                  child: const Text(
                    'Calendar',
                    style: TextStyle(
                      color: AkeaColors.plum,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
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
                            padding: EdgeInsets.fromLTRB(
                              wide ? 32 : 20,
                              20,
                              wide ? 32 : 20,
                              24,
                            ),
                            children: [
                              if (vm.error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  vm.error!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
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

// ------------------------------------------------------------
// MOBILE LAYOUT
// ------------------------------------------------------------

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.vm});

  final AnalyticsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatCard(
          label: 'Ongoing deals',
          value: '${vm.ongoingDeals}',
        ),
        const SizedBox(height: 16),
        _StatCard(
          label: 'Past Deals',
          value: '${vm.pastDeals}',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Clients',
                value: '${vm.uniqueClients}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Confirmed',
                value: _formatRand(vm.confirmedRevenue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Swipe between the two charts on mobile.
        _SwipeableCharts(counts: vm.monthlyDealCounts),

        const SizedBox(height: 16),
        _EventTypesCard(types: vm.eventTypeCounts),
      ],
    );
  }
}

// ------------------------------------------------------------
// DESKTOP / WIDE LAYOUT
// ------------------------------------------------------------

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.vm});

  final AnalyticsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Ongoing deals',
                value: '${vm.ongoingDeals}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'Past Deals',
                value: '${vm.pastDeals}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MiniStat(
                label: 'Clients',
                value: '${vm.uniqueClients}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MiniStat(
                label: 'Confirmed',
                value: _formatRand(vm.confirmedRevenue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Both charts appear next to each other on wider screens.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ChartCard(
                counts: vm.monthlyDealCounts,
                height: 300,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: _AnnualGrowthChart(height: 300),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _EventTypesCard(types: vm.eventTypeCounts),
      ],
    );
  }
}

// ------------------------------------------------------------
// MOBILE SWIPEABLE CHARTS
// ------------------------------------------------------------

class _SwipeableCharts extends StatefulWidget {
  const _SwipeableCharts({required this.counts});

  final List<MonthlyDealCount> counts;

  @override
  State<_SwipeableCharts> createState() => _SwipeableChartsState();
}

class _SwipeableChartsState extends State<_SwipeableCharts> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 290,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _ChartCard(
                counts: widget.counts,
                height: 290,
              ),
              const _AnnualGrowthChart(height: 290),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PageIndicator(
              active: _currentPage == 0,
              label: 'Monthly deals',
              onTap: () => _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
            const SizedBox(width: 10),
            _PageIndicator(
              active: _currentPage == 1,
              label: 'Business growth',
              onTap: () => _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Swipe left or right to view charts',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: active ? AkeaColors.plum : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AkeaColors.plum : AkeaColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AkeaColors.ink,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// MONTHLY DEALS BAR CHART
// ------------------------------------------------------------

class _ChartCard extends StatelessWidget {
  final List<MonthlyDealCount> counts;
  final double height;

  const _ChartCard({
    required this.counts,
    this.height = 210,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = counts.isEmpty
        ? 1
        : counts
            .map((c) => c.count)
            .fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deals by month',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: counts.every((c) => c.count == 0)
                ? const Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final month in counts)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: month.count == 0
                                          ? 0
                                          : (month.count / maxVal)
                                              .clamp(0.04, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AkeaColors.plum,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  month.label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
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
    );
  }
}

// ------------------------------------------------------------
// ANNUAL BUSINESS GROWTH CHART
// Temporary demonstration data. Replace with Supabase later.
// ------------------------------------------------------------

class _AnnualGrowthChart extends StatelessWidget {
  const _AnnualGrowthChart({this.height = 290});

  final double height;

  static const List<_YearRevenue> sampleData = [
    _YearRevenue(year: '2020', revenue: 12000),
    _YearRevenue(year: '2021', revenue: 18000),
    _YearRevenue(year: '2022', revenue: 26000),
    _YearRevenue(year: '2023', revenue: 42000),
    _YearRevenue(year: '2024', revenue: 58000),
    _YearRevenue(year: '2025', revenue: 76000),
    _YearRevenue(year: '2026', revenue: 92000),
  ];

  String _formatValue(double value) {
    if (value >= 1000) {
      return 'R${(value / 1000).toStringAsFixed(0)}k';
    }
    return 'R${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final maxRevenue = sampleData
        .map((item) => item.revenue)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business growth',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          const Text(
            'Illustrative annual booking value',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final item in sampleData)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatValue(item.revenue),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor:
                                    (item.revenue / maxRevenue)
                                        .clamp(0.04, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9B789F),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.year,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black54,
                            ),
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
    );
  }
}

class _YearRevenue {
  final String year;
  final double revenue;

  const _YearRevenue({
    required this.year,
    required this.revenue,
  });
}

// ------------------------------------------------------------
// STATISTICS CARDS
// ------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// EVENT TYPES
// ------------------------------------------------------------

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
          const Text(
            'Event types',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (types.isEmpty)
            const Text(
              'No event types yet',
              style: TextStyle(color: Colors.black54),
            )
          else
            for (final type in types)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(type.type)),
                    Text(
                      '${type.count}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
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

// ------------------------------------------------------------
// HELPERS
// ------------------------------------------------------------

String _formatRand(double value) {
  final abs = value.abs();

  if (abs >= 1000) {
    return 'R${(value / 1000).toStringAsFixed(1)}k';
  }

  return 'R${value.toStringAsFixed(0)}';
}

final _cardDecoration = BoxDecoration(
  color: AkeaColors.card,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: AkeaColors.border),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ],
);
