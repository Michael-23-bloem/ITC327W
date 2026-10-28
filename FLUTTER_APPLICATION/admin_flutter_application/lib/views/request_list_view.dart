import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/order_item_viewmodel.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';

// Same warm palette as the rest of the admin app.
class _Palette {
  static const ink = Color(0xFF2B2621);
  static const muted = Color(0xFF8A8178);
  static const gold = Color(0xFFCE9448);
  static const card = Color(0xFFF7F6F3);
  static const pill = Color(0xFFBDBAB5);
  static const track = Color(0xFFECECEC);
  static const overdue = Color(0xFFB4533D);
}

class RequestsListView extends StatefulWidget {
  const RequestsListView({super.key});

  @override
  State<RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<RequestsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderViewModel>().loadQuotations();
    });
  }

  // How long is left on the 24h decision window for a fresh request.
  // Returns null once the status has moved past request_sent, since the
  // countdown only applies before anyone has responded.
  Duration? _timeLeft(Order o) {
    if (o.status != OrderStatus.requestSent) return null;

    // NOTE: assumes Order has a `createdAt` (DateTime) field. Needed to
    // know when the 24h window started — send me order.dart if this
    // field doesn't exist yet, so I can add it against the real column
    // name (likely 'created_at').
    // ignore: avoid_dynamic_calls
    final created = (o as dynamic).createdAt as DateTime?;
    if (created == null) return null;

    return const Duration(hours: 24) - DateTime.now().difference(created);
  }

  // Friendlier, screen-specific wording than the raw status label.
  String _pillText(Order o) {
    final left = _timeLeft(o);

    if (left != null) {
      if (left.isNegative) return 'Overdue';
      final hours = left.inHours;
      return hours < 1 ? '<1h left' : '${hours}h left';
    }

    if (o.status == OrderStatus.quotationApproved) return 'Awaiting deposit';

    return OrderStatus.label(o.status);
  }

  bool _isOverdue(Order o) => _timeLeft(o)?.isNegative ?? false;

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.requestSent:
        return const Color(0xFF3976B8); // Blue
      case OrderStatus.inContact:
        return const Color(0xFFB7791F); // Amber
      case OrderStatus.quotationApproved:
        return const Color(0xFF278568); // Green
      case OrderStatus.orderConfirmed:
        return const Color(0xFF6B59A3); // Purple
      case OrderStatus.depositReceived:
        return const Color(0xFF287D78); // Teal
      case OrderStatus.preparationsBegin:
        return const Color(0xFFD97736); // Orange
      case OrderStatus.completed:
        return const Color(0xFF34804A); // Dark green
      case OrderStatus.declined:
        return const Color(0xFFB4533D); // Red
      case OrderStatus.cancelled:
        return const Color(0xFF777777); // Grey
      default:
        return const Color(0xFF8A8178);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final requests = vm.quotations;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: vm.loadQuotations,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const Text(
                      'Requests',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _Palette.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Request decision due within 24hrs',
                      style: TextStyle(fontSize: 13, color: _Palette.muted),
                    ),
                    const SizedBox(height: 20),
                    if (requests.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'No pending requests',
                            style: TextStyle(color: _Palette.muted),
                          ),
                        ),
                      )
                    else
                      ...requests.map((o) => _requestCard(o)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _requestCard(Order o) {
    final progress = OrderStatus.steps.contains(o.status)
        ? (OrderStatus.stepIndex(o.status) + 1) / OrderStatus.steps.length
        : 0.15;

    final overdue = _isOverdue(o);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openRequest(o),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o.customerName ?? o.customerEmailOrId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _Palette.ink,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isOverdue(o)
                            ? _Palette.overdue
                            : _statusColor(o.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _pillText(o),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    /*Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: overdue ? _Palette.overdue : _Palette.pill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _pillText(o),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),*/
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: _Palette.track,
                    valueColor: const AlwaysStoppedAnimation(_Palette.gold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openRequest(Order o) async {
    final orderVm = context.read<OrderViewModel>();
    final itemVm = context.read<OrderItemViewModel>();

    await orderVm.selectOrder(o.id);
    await itemVm.loadForOrder(o.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestDetailSheet(order: orderVm.selected ?? o),
    );
  }
}

class _RequestDetailSheet extends StatelessWidget {
  final Order order;
  const _RequestDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final itemVm = context.watch<OrderItemViewModel>();

    final total = itemVm.items.fold<double>(
      0,
      (sum, it) => sum + (it.priceAtTime * it.quantity),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFBDBAB5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Requested Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _Palette.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'View in full',
                        style: TextStyle(
                          color: _Palette.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Desc',
                          style: TextStyle(color: _Palette.muted, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty',
                          style: TextStyle(color: _Palette.muted, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Amt',
                          style: TextStyle(color: _Palette.muted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  if (itemVm.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    // NOTE: shows productId as a placeholder — the real
                    // item name needs to be added to the Order_item model
                    // (it's already joined in OrderItemService but not
                    // yet carried through to Order_item).
                    ...itemVm.items.map(
                      (it) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                it.productId ?? it.packageId ?? 'Item',
                                style: const TextStyle(color: _Palette.ink),
                              ),
                            ),
                            Expanded(flex: 2, child: Text('${it.quantity}')),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'R${it.priceAtTime.toStringAsFixed(0)}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Estimated Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _Palette.ink,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _Palette.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'R${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Event type',
                    style: TextStyle(fontSize: 12, color: _Palette.muted),
                  ),
                  Text(
                    order.eventType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _Palette.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: wire to whatever "contact client" action exists
                      // (e.g. open email/phone, or call editQuotation flow).
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Contact Client'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: wire to the actual confirm action — likely
                      // validateEft or a dedicated "confirm order" call.
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Palette.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
