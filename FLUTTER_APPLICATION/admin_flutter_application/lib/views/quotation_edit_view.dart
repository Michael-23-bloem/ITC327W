
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/order_viewmodel.dart';
import '../models/quotation.dart';
import '../theme/akea_theme.dart';
import '../widgets/akea_ui.dart';

class QuotationEditView extends StatefulWidget {
  final String orderId;

  const QuotationEditView({
    super.key,
    required this.orderId,
  });

  @override
  State<QuotationEditView> createState() =>
      _QuotationEditViewState();
}

class _QuotationEditViewState extends State<QuotationEditView> {
  final _formKey = GlobalKey<FormState>();

  final _transport = TextEditingController();
  final _service = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  int? _currentVersion;

  @override
  void initState() {
    super.initState();
    _loadQuotation();
  }

  Future<void> _loadQuotation() async {
    try {
      final quotation = await context
          .read<OrderViewModel>()
          .loadQuotationForEdit(widget.orderId);

      if (!mounted) return;

      _transport.text =
          (quotation?['transportation_fee'] ?? 0).toString();

      _service.text =
          (quotation?['service_fee'] ?? 0).toString();

      _currentVersion =
          (quotation?['version'] as num?)?.toInt();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');

    if (amount == null || !amount.isFinite) {
      return 'Enter a valid amount.';
    }

    if (amount < 0) {
      return 'Amount cannot be negative.';
    }

    return null;
  }

  double get _subtotal {
    final vm = context.read<OrderViewModel>();

    return vm.quotationItems.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  double get _estimatedTotal {
    final transport = double.tryParse(_transport.text) ?? 0;
    final service = double.tryParse(_service.text) ?? 0;

    return _subtotal + transport + service;
  }

  Future<void> _showItemDialog({int? index}) async {
    final vm = context.read<OrderViewModel>();

    final existing = index == null
        ? null
        : vm.quotationItems[index];

    final nameController = TextEditingController(
      text: existing?.productName ?? '',
    );

    final quantityController = TextEditingController(
      text: existing?.quantity.toString() ?? '1',
    );

    final priceController = TextEditingController(
      text: existing?.unitPrice.toString() ?? '0',
    );

    final result = await showDialog<QuotationItem>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            existing == null ? 'Add quotation item' : 'Edit quotation item',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Unit price (R)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final quantity =
                    int.tryParse(quantityController.text.trim());
                final price =
                    double.tryParse(priceController.text.trim());

                if (name.isEmpty ||
                    quantity == null ||
                    quantity <= 0 ||
                    price == null ||
                    !price.isFinite ||
                    price < 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid name, quantity and price.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  QuotationItem(
                    productId: existing?.productId,
                    packageId: existing?.packageId,
                    productName: name,
                    imageUrl: existing?.imageUrl,
                    quantity: quantity,
                    unitPrice: price,
                  ),
                );
              },
              child: const Text('Save item'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      if (index == null) {
        vm.quotationItems.add(result);
      } else {
        vm.quotationItems[index] = result;
      }
    });
  }

  Future<void> _saveQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<OrderViewModel>();

    if (vm.quotationItems.isEmpty) {
      setState(() => _error = 'Add at least one quotation item.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      vm.transportationFee = double.parse(_transport.text.trim());
      vm.serviceFee = double.parse(_service.text.trim());

      await vm.editQuotation(widget.orderId);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _buildOriginalItems(OrderViewModel vm) {
    return AkeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Original customer request',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'These are the items originally requested by the customer. '
            'They cannot be edited here.',
            style: TextStyle(color: AkeaColors.muted),
          ),
          const SizedBox(height: 12),
          if (vm.originalOrderItems.isEmpty)
            const Text('No original items found.')
          else
            ...vm.originalOrderItems.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productName),
                subtitle: Text(
                  'Quantity: ${item.quantity}  •  '
                  'Unit price: R${item.unitPrice.toStringAsFixed(2)}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuotationItems(OrderViewModel vm) {
    return AkeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Editable quotation items',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (vm.quotationItems.isEmpty)
            const Text('No quotation items added yet.')
          else
            ...List.generate(vm.quotationItems.length, (index) {
              final item = vm.quotationItems[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productName),
                subtitle: Text(
                  '${item.quantity} × R${item.unitPrice.toStringAsFixed(2)}'
                  ' = R${item.totalPrice.toStringAsFixed(2)}',
                ),
                trailing: Wrap(
                  spacing: 0,
                  children: [
                    IconButton(
                      tooltip: 'Edit item',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showItemDialog(index: index),
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AkeaColors.statusDangerInk,
                      ),
                      onPressed: () {
                        setState(() {
                          vm.quotationItems.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showItemDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add custom item'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transport.dispose();
    _service.dispose();
    super.dispose();
  }

  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title:  const AkeaPageHeader(
            title: 'Edit quotation',
            subtitle: 'Review the original request and prepare a quotation',
          ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
         
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Consumer<OrderViewModel>(
              builder: (context, vm, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_currentVersion != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Current quotation: Version $_currentVersion. '
                            'Saving creates Version ${_currentVersion! + 1}.',
                            style: const TextStyle(
                              color: AkeaColors.muted,
                            ),
                          ),
                        ),

                      _buildOriginalItems(vm),
                      const SizedBox(height: 16),
                      _buildQuotationItems(vm),
                      const SizedBox(height: 20),

                      AkeaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Quotation fees',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),

                            const AkeaFieldLabel('Transportation fee (R)'),
                            TextFormField(
                              controller: _transport,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: _validateAmount,
                              onChanged: (_) => setState(() {}),
                            ),

                            const SizedBox(height: 16),

                            const AkeaFieldLabel('Service fee (R)'),
                            TextFormField(
                              controller: _service,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: _validateAmount,
                              onChanged: (_) => setState(() {}),
                            ),

                            const Divider(height: 32),

                            _totalRow('Items subtotal', _subtotal),
                            const SizedBox(height: 8),
                            _totalRow(
                              'Transportation',
                              double.tryParse(_transport.text) ?? 0,
                            ),
                            const SizedBox(height: 8),
                            _totalRow(
                              'Service fee',
                              double.tryParse(_service.text) ?? 0,
                            ),
                            const Divider(height: 24),
                            _totalRow(
                              'Estimated total',
                              _estimatedTotal,
                              bold: true,
                            ),
                          ],
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: AkeaColors.statusDangerInk,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      AkeaButton(
                        label: 'Save new version',
                        expand: true,
                        loading: _saving,
                        onPressed: _saveQuotation,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    ),
  );
}

  Widget _totalRow(
    String label,
    double amount, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'R${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
