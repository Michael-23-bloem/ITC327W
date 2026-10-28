import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/order_item_viewmodel.dart';

const Color kPageBg = Color(0xFFF8F4ED);
const Color kGold = Color(0xFFB58A45);
const Color kDarkGold = Color(0xFF926A30);
const Color kDarkText = Color(0xFF4A3425);
const Color kCardBorder = Color(0xFFECE2D3);

class QuotationDetailView extends StatefulWidget {
  final String orderId;

  const QuotationDetailView({super.key, required this.orderId});

  @override
  State<QuotationDetailView> createState() => _QuotationDetailViewState();
}

class _QuotationDetailViewState extends State<QuotationDetailView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<OrderViewModel>().selectOrder(widget.orderId);
      context.read<OrderItemViewModel>().loadForOrder(widget.orderId);
    });
  }

  
Future<void> _showValidateDepositDialog(String orderId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirm Deposit Payment'),
      content: const Text(
        'Have you verified that the customer’s EFT deposit '
        'has been received in the business bank account?\n\n'
        'Confirming will validate the payment and convert '
        'the request into a booking.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Confirm Deposit'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  try {
    await context.read<OrderViewModel>().validateEft(orderId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deposit validated and booking created successfully.'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not validate payment: $e'),
      ),
    );
  }
}


  bool get _isBookingStage {
    final status = context
        .read<OrderViewModel>()
        .selected
        ?.status
        .toString()
        .toLowerCase()
        .replaceAll('_', ' ')
        .trim();

    if (status == null) return false;

    return status.contains('confirmed') ||
        status.contains('booked') ||
        status.contains('in progress') ||
        status.contains('ongoing') ||
        status.contains('completed');
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('completed')) {
      return Colors.green.shade700;
    }

    if (value.contains('confirmed') || value.contains('booked')) {
      return Colors.teal.shade700;
    }

    if (value.contains('reject') || value.contains('cancel')) {
      return Colors.red.shade700;
    }

    if (value.contains('progress') || value.contains('review')) {
      return kDarkGold;
    }

    return Colors.blueGrey.shade700;
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
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: kGold.withOpacity(0.07),
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
              Icon(icon, color: kDarkGold),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kDarkText,
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
            width: 115,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: kDarkText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();
    final itemVm = context.watch<OrderItemViewModel>();
    final o = orderVm.selected;

    if (orderVm.loading || o == null) {
      return const Scaffold(
        backgroundColor: kPageBg,
        body: Center(child: CircularProgressIndicator(color: kGold)),
      );
    }

    final status = o.status.toString();
    final eventDate = o.eventDate.toLocal().toString().split(' ').first;

    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kDarkText,
        elevation: 0,
        title: const Text(
          'Quotation Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page heading
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Request overview',
                            style: TextStyle(
                              color: kDarkText,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Quotation #${o.id.substring(0, o.id.length < 8 ? o.id.length : 8)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Customer details
                _sectionCard(
                  title: 'Customer Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _detailRow(
                      'Customer',
                      (o.customerName?.isNotEmpty == true)
                          ? o.customerName!
                          : 'Customer',
                    ),
                    _detailRow(
                      'Customer Email',
                      o.customerEmail ?? 'Email not available',
                    ),
                    _detailRow('Customer ID', o.customerId),
                  ],
                ),

                /* _sectionCard(
                  title: 'Customer Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _detailRow(
                      'Customer',
                      o.customerName ?? o.customerEmailOrId,
                    ),
                    _detailRow('Customer ID / Email', o.customerEmailOrId),
                  ],
                ),*/
                const SizedBox(height: 16),

                // Event details
                _sectionCard(
                  title: 'Event Overview',
                  icon: Icons.event_outlined,
                  children: [
                    _detailRow('Event type', o.eventType.toString()),
                    _detailRow('Event date', eventDate),
                    _detailRow('Current status', status),
                  ],
                ),

                const SizedBox(height: 16),

                // Requested items
                _sectionCard(
                  title: 'Requested Items',
                  icon: Icons.inventory_2_outlined,
                  children: [
                    if (itemVm.items.isEmpty)
                      const Text(
                        'No requested items were found for this request.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      ...itemVm.items.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kPageBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.celebration_outlined,
                                color: kDarkGold,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Item ${item.productId}',
                                  style: const TextStyle(
                                    color: kDarkText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  color: kDarkGold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Available actions
                const Text(
                  'Actions',
                  style: TextStyle(
                    color: kDarkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/quotations/${o.id}/edit');
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Quotation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: () {
                        // Opens your existing payment validation page.
                        onPressed: () => _showValidateDepositDialog(o.id);
                        //context.push('/quotations/${o.id}/validate');
                      },
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Validate Payment'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kDarkGold,
                        side: const BorderSide(color: kGold),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),

                    if (_isBookingStage)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push('/bookings/${o.id}/progress');
                        },
                        icon: const Icon(Icons.trending_up_rounded),
                        label: const Text('Update Progress'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF47734C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                      ),

                    if (_isBookingStage)
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/bookings/${o.id}');
                        },
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('View Booking'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kDarkText,
                          side: const BorderSide(color: kCardBorder),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
