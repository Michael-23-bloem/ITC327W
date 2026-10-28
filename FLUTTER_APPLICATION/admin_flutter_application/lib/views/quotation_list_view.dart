import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/akea_ui.dart';

class QuotationListView extends StatefulWidget {
  const QuotationListView({super.key, this.orderId});
  final String? orderId;

  @override
  State<QuotationListView> createState() => _QuotationListViewState();
}

class _QuotationListViewState extends State<QuotationListView> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.orderId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<OrderViewModel>();
      vm.loadQuotations().then((_) {
        if (!mounted) return;
        final id = _selectedId ?? (vm.quotations.isNotEmpty ? vm.quotations.first.id : null);
        if (id != null) {
          setState(() => _selectedId = id);
          vm.selectOrder(id);
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant QuotationListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orderId != null && widget.orderId != _selectedId) {
      _selectedId = widget.orderId;
      context.read<OrderViewModel>().selectOrder(widget.orderId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final selected = vm.quotations.cast<Order?>().firstWhere(
          (o) => o!.id == _selectedId,
          orElse: () => vm.selected,
        );

    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          AkeaPageHeader(
            title: 'Quotation requests',
            subtitle: 'Review each request and confirm or decline within 24 hours',
            actions: [
              AkeaButton(
                label: 'Confirm',
                onPressed: selected == null
                    ? null
                    : () async {
                        await vm.confirmQuotation(selected.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quotation confirmed')),
                          );
                        }
                      },
              ),
            ],
          ),
          if (vm.loading && vm.quotations.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 980;
                final list = _RequestList(
                  orders: vm.quotations,
                  selectedId: _selectedId,
                  onSelect: (id) {
                    setState(() => _selectedId = id);
                    context.go('/quotations/$id');
                    vm.selectOrder(id);
                  },
                );
                final detail = selected == null
                    ? const AkeaCard(
                        child: Text(
                          'Select a request to review it.',
                          style: TextStyle(color: AkeaColors.muted),
                        ),
                      )
                    : _RequestDetail(order: vm.selected?.id == selected.id ? vm.selected! : selected);
                if (stacked) {
                  return Column(
                    children: [
                      list,
                      const SizedBox(height: 16),
                      detail,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 280, child: list),
                    const SizedBox(width: 20),
                    Expanded(child: detail),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.orders,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Order> orders;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const AkeaCard(child: Text('No pending quotations'));
    }
    return Column(
      children: [
        for (final o in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: o.id == selectedId ? const Color(0xFFF4E7C8) : AkeaColors.card,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(o.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: o.id == selectedId
                        ? Border.all(color: AkeaColors.goldSoft)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              '${o.eventType} · ${akeaDate(o.eventDate)}',
                              style: const TextStyle(color: AkeaColors.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      AkeaStatusChip.forStatus(o.status, hoursLeft: o.hoursLeft),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RequestDetail extends StatelessWidget {
  const _RequestDetail({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(order.displayName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          order.status == 'pending'
              ? 'Decision due within 24 hrs'
              : order.status.replaceAll('_', ' '),
          style: const TextStyle(color: AkeaColors.muted),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 720;
            final itemsCard = AkeaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Requested items', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(child: Text('Item', style: TextStyle(color: AkeaColors.muted))),
                      SizedBox(width: 40, child: Text('Qty', style: TextStyle(color: AkeaColors.muted))),
                      SizedBox(
                        width: 80,
                        child: Text('Amt', textAlign: TextAlign.right, style: TextStyle(color: AkeaColors.muted)),
                      ),
                    ],
                  ),
                  const Divider(color: AkeaColors.border),
                  if (order.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No line items yet', style: TextStyle(color: AkeaColors.muted)),
                    )
                  else
                    ...order.items.map(
                      (it) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(child: Text(it.name)),
                            SizedBox(width: 40, child: Text('${it.quantity}')),
                            SizedBox(
                              width: 80,
                              child: Text(akeaMoney(it.amount), textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D9B0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('Estimated total', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          akeaMoney(order.computedTotal),
                          style: const TextStyle(
                            color: AkeaColors.purple,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AkeaButton(
                    label: 'View full quotation',
                    style: AkeaButtonStyle.outline,
                    expand: true,
                    onPressed: () => context.push('/quotations/${order.id}/edit'),
                  ),
                ],
              ),
            );
            final infoCard = AkeaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event information', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  const AkeaFieldLabel('Event type'),
                  Text(order.eventType, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const AkeaFieldLabel('Event date'),
                  Text(akeaDate(order.eventDate), style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const AkeaFieldLabel('Venue'),
                  Text(order.venue ?? 'TBC', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const AkeaFieldLabel('Guests'),
                  Text('${order.guestCount}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const AkeaFieldLabel('Additional info'),
                  Text(order.notes?.isNotEmpty == true ? order.notes! : '—'),
                ],
              ),
            );
            if (stacked) {
              return Column(children: [itemsCard, const SizedBox(height: 16), infoCard]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: itemsCard),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: infoCard),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            AkeaButton(
              label: 'Contact client',
              style: AkeaButtonStyle.outline,
              onPressed: () {
                final email = order.customerEmail ?? '';
                Clipboard.setData(ClipboardData(text: email));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(email.isEmpty ? 'No email on file' : 'Copied $email')),
                );
              },
            ),
            AkeaButton(
              label: 'Edit and send back',
              style: AkeaButtonStyle.gold,
              onPressed: () => context.push('/quotations/${order.id}/edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Contact the client if the request doesn’t fit the way we work.',
          style: TextStyle(color: AkeaColors.muted, fontSize: 13),
        ),
      ],
    );
  }
}
