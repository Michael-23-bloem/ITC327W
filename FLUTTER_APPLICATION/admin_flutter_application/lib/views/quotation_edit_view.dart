
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/order_viewmodel.dart';
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

  final _total = TextEditingController();
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

      if (quotation != null) {
        _total.text =
            (quotation['estimated_total'] ?? '').toString();
        _transport.text =
            (quotation['transportation_fee'] ?? 0).toString();
        _service.text =
            (quotation['service_fee'] ?? 0).toString();

        _currentVersion =
            (quotation['version'] as num?)?.toInt();
      } else {
        // First quotation for this order.
        _total.text = '0';
        _transport.text = '0';
        _service.text = '0';
      }
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

    if (amount == null) {
      return 'Enter a valid amount.';
    }

    if (!amount.isFinite || amount < 0) {
      return 'Enter an amount of zero or more.';
    }

    return null;
  }

  Future<void> _saveQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await context.read<OrderViewModel>().editQuotation(
            widget.orderId,
            double.parse(_total.text.trim()),
            double.parse(_transport.text.trim()),
            double.parse(_service.text.trim()),
          );

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

  @override
  void dispose() {
    _total.dispose();
    _transport.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          const AkeaPageHeader(
            title: 'Edit quotation',
            subtitle: 'Send a revised total back to the client',
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            AkeaCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_currentVersion != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Current quotation: Version $_currentVersion. '
                          'Saving will create Version ${_currentVersion! + 1}.',
                          style: const TextStyle(color: AkeaColors.muted),
                        ),
                      ),
                    const AkeaFieldLabel('Estimated total (R)'),
                    TextFormField(
                      controller: _total,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    const AkeaFieldLabel('Transportation fee (R)'),
                    TextFormField(
                      controller: _transport,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    const AkeaFieldLabel('Service fee (R)'),
                    TextFormField(
                      controller: _service,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateAmount,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: AkeaColors.statusDangerInk),
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
              ),
            ),
        ],
      ),
    );
  }
}
