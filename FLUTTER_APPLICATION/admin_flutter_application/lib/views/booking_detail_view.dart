
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/order_item_viewmodel.dart';
import '../widgets/akea_ui.dart';

class BookingDetailView extends StatefulWidget {
  const BookingDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  State<BookingDetailView> createState() => _BookingDetailViewState();
}

class _BookingDetailViewState extends State<BookingDetailView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<OrderViewModel>().selectOrder(widget.orderId);
      context.read<OrderItemViewModel>().loadForOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();
    final itemVm = context.watch<OrderItemViewModel>();
    final o = orderVm.selected;

    if (orderVm.loading || o == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AkeaColors.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F1E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF51483F),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/bookings');
            }
          },
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Color(0xFF51483F)),
        ),
      ),
      body: AkeaPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 950),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page heading and update button.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AkeaPageHeader(
                          title: o.displayName,
                          subtitle:
                              'Booking for ${akeaDate(o.eventDate)}',
                        ),
                      ),
                      const SizedBox(width: 16),
                      AkeaButton(
                        label: 'Update progress',
                        onPressed: () {
                          context.push('/bookings/${o.id}/progress');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Booking status.
                  _sectionCard(
                    title: 'Booking Status',
                    icon: Icons.assignment_turned_in_outlined,
                    children: [
                      _detailRow('Current status', _statusLabel(o.status)),
                      _detailRow(
                        'Booking reference',
                        o.id.substring(
                          0,
                          o.id.length < 8 ? o.id.length : 8,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Customer details.
                  _sectionCard(
                    title: 'Customer Details',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _detailRow(
                        'Customer',
                        o.customerName?.isNotEmpty == true
                            ? o.customerName!
                            : 'Customer',
                      ),
                      _detailRow(
                        'Email',
                        o.customerEmail ?? 'Email not available',
                      ),
                      _detailRow(
                        'Phone number',
                        o.customerPhone ?? 'Phone number not available',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Event information.
                  _sectionCard(
                    title: 'Event Information',
                    icon: Icons.event_outlined,
                    children: [
                      _detailRow('Event type', o.eventType),
                      _detailRow(
                        'Event date',
                        akeaDate(o.eventDate),
                      ),
                      _detailRow('Venue', o.venue ?? 'Not provided'),
                      _detailRow('Theme', o.theme ?? 'Not specified'),
                      _detailRow('Guest count', '${o.guestCount}'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Additional notes.
                  _sectionCard(
                    title: 'Additional Information',
                    icon: Icons.notes_rounded,
                    children: [
                      _detailRow(
                        'Customer notes',
                        o.notes?.trim().isNotEmpty == true
                            ? o.notes!
                            : 'No additional notes provided.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Requested items.
                  _sectionCard(
                    title: 'Requested Items',
                    icon: Icons.inventory_2_outlined,
                    children: [
                      if (itemVm.loading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (itemVm.items.isEmpty)
                        const Text(
                          'No requested items were found for this booking.',
                          style: TextStyle(color: AkeaColors.muted),
                        )
                      else
                        ...itemVm.items.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AkeaColors.cream,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item.imageUrl != null &&
                                          item.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          item.imageUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _itemPlaceholder(),
                                        )
                                      : _itemPlaceholder(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AkeaColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Unit price: R${item.priceAtTime.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AkeaColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'x${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AkeaColors.plum,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'R${item.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AkeaColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quotation summary.
                  _sectionCard(
                    title: 'Quotation Summary',
                    icon: Icons.receipt_long_outlined,
                    children: [
                      _detailRow(
                        'Estimated total',
                        _money(o.estimatedTotal),
                      ),
                      _detailRow(
                        'Transportation fee',
                        _money(o.transportFee),
                      ),
                      _detailRow(
                        'Service fee',
                        _money(o.serviceFee),
                      ),
                      const Divider(color: AkeaColors.border),
                      _detailRow(
                        'Quotation total',
                        _money(o.computedTotal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AkeaColors.border),
        boxShadow: [
          BoxShadow(
            color: AkeaColors.gold.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AkeaColors.plum),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AkeaColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: AkeaColors.muted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AkeaColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemPlaceholder() {
    return const SizedBox(
      width: 60,
      height: 60,
      child: Icon(
        Icons.celebration_outlined,
        color: AkeaColors.plum,
      ),
    );
  }

  String _money(double amount) {
    return 'R ${amount.toStringAsFixed(2)}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'deposit_received':
        return 'Deposit Received';
      case 'preparations_begin':
        return 'In Preparation';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'declined':
        return 'Declined';
      default:
        return status.replaceAll('_', ' ');
    }
  }
}