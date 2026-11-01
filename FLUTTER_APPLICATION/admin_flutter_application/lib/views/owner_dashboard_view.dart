
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/akea_ui.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<OrderViewModel>();
      vm.loadQuotations();
      vm.loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();

    final pending = orderVm.quotations
        .where((o) => o.status == OrderStatus.requestSent)
        .toList();

    final deposits = orderVm.quotations
        .where((o) => o.status == OrderStatus.quotationApproved)
        .toList();

    // Requests requiring a decision within the next 6 hours.
    final urgent = pending.where((o) => o.hoursLeft <= 6).toList();

    // Upcoming bookings: events happening within the next 14 days.
    final today = DateTime.now();

    final startDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final endDate = startDate.add(const Duration(days: 14));

    final upcoming = orderVm.bookings.where((order) {
      final eventDate = DateTime(
        order.eventDate.year,
        order.eventDate.month,
        order.eventDate.day,
      );

      final isWithinTwoWeeks =
          !eventDate.isBefore(startDate) &&
          !eventDate.isAfter(endDate);

      final isActive =
          order.status != 'cancelled' &&
          order.status != 'declined';

      return isWithinTwoWeeks && isActive;
    }).toList();

    // Sort the filtered list: nearest event first.
    upcoming.sort(
      (a, b) => a.eventDate.compareTo(b.eventDate),
    );

    // Display a maximum of four bookings.
    final soon = upcoming.take(4).toList();

    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          if (urgent.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AkeaColors.banner,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: AkeaColors.bannerInk,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${urgent.first.displayName}’s quotation request has ${urgent.first.hoursLeft} hours left for a decision.',
                      style: const TextStyle(
                        color: AkeaColors.bannerInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          LayoutBuilder(
            builder: (context, constraints) {
              const tiles = [
                _DashTileData(
                  title: 'Event products',
                  subtitle: 'Upload décor items',
                  icon: Icons.inventory_2_outlined,
                  route: '/decor/upload',
                ),
                _DashTileData(
                  title: 'Quotation requests',
                  subtitle: 'awaiting a decision',
                  icon: Icons.description_outlined,
                  route: '/quotations',
                ),
                _DashTileData(
                  title: 'Portfolio',
                  subtitle: 'Upload recent work',
                  icon: Icons.photo_outlined,
                  route: '/portfolio/upload',
                ),
                _DashTileData(
                  title: 'Bookings',
                  subtitle: 'Client reports',
                  icon: Icons.calendar_month_outlined,
                  route: '/bookings',
                ),
                _DashTileData(
                  title: 'Analysis',
                  subtitle: 'Client analytics',
                  icon: Icons.bar_chart_outlined,
                  route: '/analytics',
                ),
                _DashTileData(
                  title: 'Accounts',
                  subtitle: 'Manage client accounts',
                  icon: Icons.person_outline,
                  route: '/accounts',
                ),
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tiles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth >= 980 ? 3 : 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio:
                      constraints.maxWidth < 640 ? 0.95 : 2.15,
                ),
                itemBuilder: (context, i) {
                  final tile = tiles[i];

                  final subtitle = tile.title == 'Quotation requests'
                      ? '${pending.length} awaiting a decision'
                      : tile.subtitle;

                  return _DashCard(
                    data: tile,
                    subtitle: subtitle,
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 860;

              final needs = [
                ...pending.map(
                  (o) => _NeedItem(
                    title: '${o.displayName} · quotation decision',
                    chip: AkeaStatusChip.forStatus(
                      o.status,
                      hoursLeft: o.hoursLeft,
                    ),
                    icon: Icons.schedule,
                  ),
                ),
                ...deposits.map(
                  (o) => _NeedItem(
                    title: '${o.displayName} · EFT deposit',
                    chip: AkeaStatusChip.forStatus(o.status),
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ];

              final left = AkeaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Needs attention',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (needs.isEmpty)
                      const Text(
                        'Nothing waiting right now.',
                        style: TextStyle(color: AkeaColors.muted),
                      )
                    else
                      ...needs.take(5).map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AkeaColors.cream,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  n.icon,
                                  size: 18,
                                  color: AkeaColors.muted,
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(n.title)),
                                n.chip,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );

              final right = AkeaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming bookings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (soon.isEmpty)
                      const Text(
                        'No upcoming bookings.',
                        style: TextStyle(color: AkeaColors.muted),
                      )
                    else
                      ...soon.map((o) => _UpcomingRow(order: o)),
                  ],
                ),
              );

              if (stacked) {
                return Column(
                  children: [
                    left,
                    const SizedBox(height: 16),
                    right,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 16),
                  Expanded(child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashTileData {
  const _DashTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.data,
    required this.subtitle,
  });

  final _DashTileData data;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AkeaColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(data.route),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AkeaColors.cream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      data.icon,
                      color: AkeaColors.purple,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.north_east,
                    size: 18,
                    color: AkeaColors.muted,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                data.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AkeaColors.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedItem {
  const _NeedItem({
    required this.title,
    required this.chip,
    required this.icon,
  });

  final String title;
  final Widget chip;
  final IconData icon;
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.go('/bookings/${order.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AkeaColors.cream,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D9B0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '${order.eventDate.day}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      months[order.eventDate.month - 1],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${order.eventType} · ${order.venue ?? 'Venue TBC'}',
                      style: const TextStyle(
                        color: AkeaColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              AkeaStatusChip.forStatus(order.status),
            ],
          ),
        ),
      ),
    );
  }
}
