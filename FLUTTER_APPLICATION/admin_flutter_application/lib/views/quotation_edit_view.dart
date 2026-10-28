import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/akea_ui.dart';

class QuotationEditView extends StatefulWidget {
  const QuotationEditView({super.key, required this.orderId});
  final String orderId;

  @override
  State<QuotationEditView> createState() => _EditQuotationViewState();
}

class _LineDraft {
  _LineDraft({required this.name, required this.qty, required this.amount});
  String name;
  int qty;
  double amount;
}

class _EditQuotationViewState extends State<QuotationEditView> {
  final _transport = TextEditingController();
  final _service = TextEditingController();
  final _note = TextEditingController();
  final List<_LineDraft> _lines = [];
  bool _seeded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().selectOrder(widget.orderId);
    });
  }

  @override
  void dispose() {
    _transport.dispose();
    _service.dispose();
    _note.dispose();
    super.dispose();
  }

  void _seed(Order o) {
    if (_seeded) return;
    _seeded = true;
    _transport.text = o.transportFee.toStringAsFixed(2);
    _service.text = o.serviceFee.toStringAsFixed(2);
    _note.text = o.notes ?? '';
    _lines
      ..clear()
      ..addAll(
        o.items.map((i) => _LineDraft(name: i.name, qty: i.quantity, amount: i.amount)),
      );
    if (_lines.isEmpty) {
      _lines.add(_LineDraft(name: 'Item', qty: 1, amount: 0));
    }
  }

  double get _itemsTotal => _lines.fold(0, (s, l) => s + l.amount);
  double get _total =>
      _itemsTotal +
      (double.tryParse(_transport.text) ?? 0) +
      (double.tryParse(_service.text) ?? 0);

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<OrderViewModel>().editQuotation(
          widget.orderId,
          _total,
          double.tryParse(_transport.text) ?? 0,
          double.tryParse(_service.text) ?? 0,
        );
    if (mounted) {
      setState(() => _saving = false);
      context.go('/quotations/${widget.orderId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final o = vm.selected;
    if (vm.loading && o == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (o == null) {
      return const Scaffold(body: Center(child: Text('Quotation not found')));
    }
    _seed(o);

    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          AkeaPageHeader(
            title: 'Edit quotation',
            subtitle: '${o.displayName} · ${o.eventType} · ${akeaDate(o.eventDate)}',
            actions: [
              AkeaButton(
                label: 'Cancel',
                style: AkeaButtonStyle.outline,
                onPressed: () => context.go('/quotations/${o.id}'),
              ),
              AkeaButton(label: 'Save changes', loading: _saving, onPressed: _save),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 900;
              final items = AkeaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Items', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    for (var i = 0; i < _lines.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                height: 46,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: AkeaColors.cream,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(_lines[i].name),
                              ),
                            ),
                            const SizedBox(width: 10),
                            AkeaStepperRow(
                              value: _lines[i].qty,
                              onChanged: (v) {
                                setState(() {
                                  final unit = _lines[i].qty == 0 ? 0.0 : _lines[i].amount / _lines[i].qty;
                                  _lines[i].qty = v;
                                  _lines[i].amount = unit * v;
                                });
                              },
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 80,
                              child: Text(akeaMoney(_lines[i].amount), textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                    AkeaButton(
                      label: '+ Add item',
                      style: AkeaButtonStyle.outline,
                      onPressed: () => setState(
                        () => _lines.add(_LineDraft(name: 'New item', qty: 1, amount: 0)),
                      ),
                    ),
                  ],
                ),
              );
              final fees = Column(
                children: [
                  AkeaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Additional fees', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        _feeRow('Transport fee', _transport),
                        const SizedBox(height: 12),
                        _feeRow('Service fee', _service),
                        const Divider(height: 28, color: AkeaColors.border),
                        Row(
                          children: [
                            const Text('Estimated total', style: TextStyle(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text(
                              akeaMoney(_total),
                              style: const TextStyle(
                                color: AkeaColors.purple,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AkeaFieldLabel('Event date'),
                  ),
                  InputDecorator(
                    decoration: const InputDecoration(),
                    child: Text(akeaDate(o.eventDate)),
                  ),
                  const SizedBox(height: 16),
                  AkeaButton(
                    label: 'Send updated quotation',
                    style: AkeaButtonStyle.gold,
                    expand: true,
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              );
              if (stacked) {
                return Column(children: [items, const SizedBox(height: 16), fees]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: items),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: fees),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const AkeaFieldLabel('Note to client'),
          TextField(
            controller: _note,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Add a note about changes to this quotation…',
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(
          width: 110,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixText: 'R '),
          ),
        ),
      ],
    );
  }
}
