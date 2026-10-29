import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
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
      if (mounted) context.read<OrderViewModel>().selectOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final o = vm.selected;
    if (vm.loading || o == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          AkeaPageHeader(
            title: o.displayName,
            subtitle: 'Booking for ${akeaDate(o.eventDate)}',
            actions: [
              AkeaButton(
                label: 'Update progress',
                onPressed: () => context.push('/bookings/${o.id}/progress'),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 860;
              final info = AkeaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event information', style: Theme.of(context).textTheme.titleLarge),
                    const Divider(height: 28, color: AkeaColors.border),
                    _kv('Event type', o.eventType),
                    _kv('Event due', akeaDate(o.eventDate)),
                    _kv('Venue', o.venue ?? 'TBC'),
                    _kv('Guests', '${o.guests}'),
                  ],
                ),
              );
              final requests = AkeaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ongoing requests', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    _requestRow(
                      'Quotation',
                      o.status == 'request_sent' ? 'Open' : 'Done',
                    ),
                    _requestRow(
                      'Deposit',
                      o.status == 'quotation_approved' ? 'Open' : 'Done',
                    ),
                    _requestRow('Progress', o.status.toLowerCase().contains('complete') ? 'Done' : 'Open'),
                  ],
                ),
              );
              if (stacked) {
                return Column(children: [info, const SizedBox(height: 16), requests]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: info),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: requests),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AkeaColors.muted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _requestRow(String title, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AkeaColors.cream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            AkeaStatusChip.forStatus(status),
          ],
        ),
      ),
    );
  }
}
