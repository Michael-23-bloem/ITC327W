import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/order_item_viewmodel.dart';
import '../theme/akea_theme.dart';
import '../widgets/akea_ui.dart';

const Color kPageBg = AkeaColors.bg;
const Color kGold = AkeaColors.gold;
const Color kDarkGold = AkeaColors.plum;
const Color kDarkText = AkeaColors.ink;
const Color kCardBorder = AkeaColors.border;

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
      _loadLatestQuotation();
    });
  }

  Map<String, dynamic>? _quotation;
  bool _quotationLoading = true;

  Future<void> _loadLatestQuotation() async {
    try {
      final result = await context.read<OrderViewModel>().loadQuotationForEdit(
        widget.orderId,
      );

      if (!mounted) return;

      setState(() {
        _quotation = result;
        _quotationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _quotationLoading = false;
      });

      debugPrint('Load quotation error: $e');
    }
  }

  Future<void> _contactCustomerOnWhatsApp(String customerId) async {
    try {
      // Retrieve the customer's phone number from Supabase.
      final customer = await Supabase.instance.client
          .from('profiles')
          .select('phone_number')
          .eq('id', customerId)
          .maybeSingle();

      if (!mounted) return;

      final rawPhone = customer?['phone_number']?.toString().trim() ?? '';

      if (rawPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer phone number is not available.'),
          ),
        );
        return;
      }

      // WhatsApp requires the international number without "+" or spaces.
      String phone = rawPhone.replaceAll(RegExp(r'\D'), '');

      if (phone.startsWith('00')) {
        phone = phone.substring(2);
      } else if (phone.startsWith('0')) {
        // Convert a South African local number, e.g. 082... to 2782...
        phone = '27${phone.substring(1)}';
      }

      final whatsappUri = Uri.parse('https://wa.me/$phone');

      final opened = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Please try again.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Contact customer error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to retrieve the customer contact details.'),
        ),
      );
    }
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

  Widget _buildQuotationCard() {
    if (_quotationLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final quotation = _quotation;

    if (quotation == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No quotation has been created yet.'),
        ),
      );
    }

    String money(dynamic value) {
      final amount = (value as num?)?.toDouble() ?? 0;
      return 'R ${amount.toStringAsFixed(2)}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quotation Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Version: ${quotation['version'] ?? 1}'),
            Text('Status: ${quotation['status'] ?? 'pending'}'),
            const Divider(),
            _quotationRow(
              'Estimated total',
              money(quotation['estimated_total']),
            ),
            _quotationRow(
              'Transportation fee',
              money(quotation['transportation_fee']),
            ),
            _quotationRow('Service fee', money(quotation['service_fee'])),
            if (quotation['final_total'] != null)
              _quotationRow('Final total', money(quotation['final_total'])),
          ],
        ),
      ),
    );
  }

  Widget _quotationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    _detailRow(
                      'Phone number',
                      o.customerPhone ?? 'Phone number not available',
                    ),
                    //_detailRow('Customer ID', o.customerId),
                  ],
                ),

                const SizedBox(height: 16),

                // Event details
                _sectionCard(
                  title: 'Event Overview',
                  icon: Icons.event_outlined,
                  children: [
                    _detailRow('Event type', o.eventType),
                    _detailRow('Event date', eventDate),
                    _detailRow('Venue', o.venue ?? 'Not provided'),
                    _detailRow('Theme', o.theme ?? 'Not specified'),
                    _detailRow('Guest count', '${o.guestCount}'),
                    _detailRow('Current status', status),
                  ],
                ),

                const SizedBox(height: 16),

                // Customer notes
                _sectionCard(
                  title: 'Additional Information',
                  icon: Icons.notes_rounded,
                  children: [
                    _detailRow(
                      'Customer notes',
                      (o.notes?.trim().isNotEmpty == true)
                          ? o.notes!
                          : 'No additional notes provided.',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quotation summary
                _buildQuotationCard(),

                const SizedBox(height: 16),
                // Requested items
                _sectionCard(
                  title: 'Requested Items',
                  icon: Icons.inventory_2_outlined,
                  children: [
                    if (itemVm.loading)
                      const Center(
                        child: CircularProgressIndicator(color: kGold),
                      )
                    else if (itemVm.items.isEmpty)
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    item.imageUrl != null &&
                                        item.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl!,
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const SizedBox(
                                              width: 55,
                                              height: 55,
                                              child: Icon(
                                                Icons.celebration_outlined,
                                                color: kDarkGold,
                                              ),
                                            ),
                                      )
                                    : const SizedBox(
                                        width: 55,
                                        height: 55,
                                        child: Icon(
                                          Icons.celebration_outlined,
                                          color: kDarkGold,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: const TextStyle(
                                        color: kDarkText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Unit price: R${item.priceAtTime.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.black54,
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
                                      color: kDarkGold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'R${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: kDarkText,
                                      fontWeight: FontWeight.w600,
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
                    AkeaButton(
                      label: 'Confirm quotation',
                      onPressed: () async {
                        try {
                          await context.read<OrderViewModel>().confirmQuotation(
                            o.id,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Quotation confirmed. Awaiting deposit.',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _contactCustomerOnWhatsApp(o.customerId),
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Contact Customer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade800,
                        side: BorderSide(color: Colors.green.shade700),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final saved = await context.push<bool>(
                          '/quotations/${o.id}/edit',
                        );

                        if (!mounted || saved != true) return;

                        await context.read<OrderViewModel>().selectOrder(o.id);
                        await _loadLatestQuotation();
                        // await context.read<OrderViewModel>().selectOrder(o.id);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quotation updated successfully.'),
                          ),
                        );
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
                      onPressed: () =>
                          context.push('/quotations/${o.id}/validate'),
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
