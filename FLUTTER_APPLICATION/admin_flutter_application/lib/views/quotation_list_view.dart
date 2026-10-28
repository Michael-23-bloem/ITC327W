

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/order_viewmodel.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';

class _Palette {
  static const background = Color(0xFFF7F4EF);
  static const ink = Color(0xFF2B2621);
  static const muted = Color(0xFF82766A);
  static const gold = Color(0xFFCE9448);
  static const card = Colors.white;
  static const border = Color(0xFFECE5DB);
}

class QuotationListView extends StatefulWidget {
  const QuotationListView({super.key});

  @override
  State<QuotationListView> createState() =>
      _QuotationListViewState();
}

class _QuotationListViewState extends State<QuotationListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderViewModel>().loadQuotations();
      }
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.requestSent:
        return const Color(0xFF3976B8);
      case OrderStatus.inContact:
        return const Color(0xFFB7791F);
      case OrderStatus.quotationApproved:
        return const Color(0xFF278568);
      case OrderStatus.orderConfirmed:
        return const Color(0xFF6B59A3);
      case OrderStatus.depositReceived:
        return const Color(0xFF287D78);
      case OrderStatus.preparationsBegin:
        return const Color(0xFFD97736);
      case OrderStatus.completed:
        return const Color(0xFF34804A);
      case OrderStatus.declined:
        return const Color(0xFFB4533D);
      case OrderStatus.cancelled:
        return const Color(0xFF777777);
      default:
        return _Palette.muted;
    }
  }

  int _countStatus(String status) {
    return context
        .read<OrderViewModel>()
        .quotations
        .where((order) => order.status == status)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final requests = vm.quotations;

    final newCount = _countStatus(OrderStatus.requestSent);

    final inProgressCount = requests.where((o) =>
        [
          OrderStatus.inContact,
          OrderStatus.quotationApproved,
          OrderStatus.orderConfirmed,
          OrderStatus.preparationsBegin,
        ].contains(o.status)).length;

    final depositCount = _countStatus(OrderStatus.quotationApproved);

    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: AppBar(
        backgroundColor: _Palette.background,
        foregroundColor: _Palette.ink,
        elevation: 0,
        title: const Text(
          'Akea Events',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh requests',
            onPressed: vm.loading ? null : vm.loadQuotations,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vm.loading && requests.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: _Palette.gold,
              ),
            )
          : RefreshIndicator(
              color: _Palette.gold,
              onRefresh: vm.loadQuotations,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  _buildHeader(requests.length),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _sectionTitle('Overview'),
                      const Spacer(),
                      Text(
                        '${requests.length} total requests',
                        style: const TextStyle(
                          color: _Palette.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: 'New',
                          count: newCount,
                          icon: Icons.mark_email_unread_rounded,
                          color: const Color(0xFF3976B8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          title: 'In progress',
                          count: inProgressCount,
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFFB7791F),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          title: 'Awaiting',
                          count: depositCount,
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF278568),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      _sectionTitle('Recent requests'),
                      const Spacer(),
                      const Icon(
                        Icons.sort_rounded,
                        size: 17,
                        color: _Palette.muted,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Newest first',
                        style: TextStyle(
                          color: _Palette.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (requests.isEmpty)
                    _emptyState()
                  else
                    ...requests.map(_requestCard),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3C322A),
            Color(0xFF66503B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR WORKSPACE',
                  style: TextStyle(
                    color: Color(0xFFE7C89E),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Quotation\nRequests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  count == 1
                      ? 'You have 1 request to manage.'
                      : 'You have $count requests to manage.',
                  style: const TextStyle(
                    color: Color(0xFFE2D7CB),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCE9448).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFCE9448).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Color(0xFFE7C89E),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Review within 24 hours',
                        style: TextStyle(
                          color: Color(0xFFE7C89E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFCE9448).withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Color(0xFFE7C89E),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _Palette.ink,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _Palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              color: _Palette.ink,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _Palette.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(Order order) {
    final color = _statusColor(order.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/quotations/${order.id}');
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _Palette.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E7D6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: _Palette.gold,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName ??
                            order.customerEmail ??
                            'Customer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _Palette.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.eventType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _Palette.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: _Palette.muted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${order.eventDate.day}/'
                              '${order.eventDate.month}/'
                              '${order.eventDate.year}',
                              style: const TextStyle(
                                color: _Palette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (order.venue != null &&
                          order.venue!.trim().isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: _Palette.muted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.venue!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _Palette.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 125),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        OrderStatus.label(order.status),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Palette.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 46,
            color: _Palette.gold,
          ),
          SizedBox(height: 14),
          Text(
            'No quotation requests yet',
            style: TextStyle(
              color: _Palette.ink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'New customer requests will appear here when they arrive.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Palette.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/order_viewmodel.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';

class QuotationListView extends StatefulWidget {
  const QuotationListView({super.key});

  @override
  State<QuotationListView> createState() =>
      _QuotationListViewState();
}

class _QuotationListViewState extends State<QuotationListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderViewModel>().loadQuotations();
      }
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.requestSent:
        return const Color(0xFF3976B8);
      case OrderStatus.inContact:
        return const Color(0xFFB7791F);
      case OrderStatus.quotationApproved:
        return const Color(0xFF278568);
      case OrderStatus.orderConfirmed:
        return const Color(0xFF6B59A3);
      case OrderStatus.depositReceived:
        return const Color(0xFF287D78);
      case OrderStatus.preparationsBegin:
        return const Color(0xFFD97736);
      case OrderStatus.completed:
        return const Color(0xFF34804A);
      case OrderStatus.declined:
        return const Color(0xFFB4533D);
      case OrderStatus.cancelled:
        return const Color(0xFF777777);
      default:
        return const Color(0xFF8A8178);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Requests'),
      ),
      body: vm.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : vm.quotations.isEmpty
              ? const Center(
                  child: Text('No quotation requests'),
                )
              : RefreshIndicator(
                  onRefresh: vm.loadQuotations,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: vm.quotations.length,
                    itemBuilder: (_, i) {
                      final Order o = vm.quotations[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.request_quote),
                          ),
                          title: Text(
                            o.customerName ??
                                o.customerEmail ??
                                'Customer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${o.eventType} • '
                              '${o.eventDate.day}/'
                              '${o.eventDate.month} • '
                              '${o.venue ?? ''}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 145,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(o.status),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  OrderStatus.label(o.status),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            context.push('/quotations/${o.id}');
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}*/
