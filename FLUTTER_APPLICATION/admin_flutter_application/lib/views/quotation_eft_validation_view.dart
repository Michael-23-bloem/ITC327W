import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/akea_ui.dart';

class ValidatePaymentView extends StatefulWidget {
  const ValidatePaymentView({super.key, required this.orderId});
  final String orderId;

  @override
  State<ValidatePaymentView> createState() => _ValidatePaymentViewState();
}

class _ValidatePaymentViewState extends State<ValidatePaymentView> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  bool _validated = false;
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
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final o = vm.selected;
    if (o != null && _amount.text.isEmpty && o.computedTotal > 0) {
      _amount.text = o.computedTotal.toStringAsFixed(2);
    }

    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          AkeaPageHeader(
            title: o?.displayName ?? 'Deposit',
            subtitle: 'Quotation confirmed, awaiting deposit',
            actions: [
              AkeaButton(
                label: 'Save update',
                loading: _saving,
                onPressed: () async {
                  setState(() => _saving = true);
                  if (_validated) {
                    await vm.validateEft(widget.orderId);
                  }
                  if (context.mounted) context.go('/bookings');
                },
              ),
            ],
          ),
          if (vm.loading && o == null)
            const Center(child: CircularProgressIndicator())
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 900;
                final deposit = AkeaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Deposit (EFT)', style: Theme.of(context).textTheme.titleLarge),
                          const Spacer(),
                          AkeaStatusChip.forStatus(_validated ? 'confirmed' : 'awaiting_deposit'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const AkeaFieldLabel('Deposit amount'),
                      TextField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(prefixText: 'R '),
                      ),
                      const SizedBox(height: 16),
                      const AkeaFieldLabel('Payment reference'),
                      TextField(
                        controller: _reference,
                        decoration: const InputDecoration(
                          hintText: 'Reference from the client’s EFT',
                        ),
                      ),
                      const SizedBox(height: 18),
                      AkeaButton(
                        label: 'Validate EFT payment',
                        expand: true,
                        onPressed: () async {
                          try {
                            await vm.validateEft(widget.orderId);
                            setState(() => _validated = true);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('EFT payment validated')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst('Exception: ', ''),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const Divider(height: 32, color: AkeaColors.border),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          AkeaButton(
                            label: 'Convert to booking',
                            style: AkeaButtonStyle.outline,
                            onPressed: _validated
                                ? () => context.go('/bookings/${widget.orderId}')
                                : null,
                          ),
                          AkeaButton(
                            label: 'Send finalised quotation',
                            style: AkeaButtonStyle.outline,
                            onPressed: () => context.push('/quotations/${widget.orderId}/edit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Available once the payment is validated. The booking then appears on the calendar.',
                        style: TextStyle(color: AkeaColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                );
                final steps = AkeaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next steps', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      const AkeaTrackerStep(
                        title: 'Quotation confirmed',
                        subtitle: 'Completed',
                        state: AkeaStepState.done,
                      ),
                      AkeaTrackerStep(
                        title: 'EFT payment validated',
                        subtitle: _validated ? 'Completed' : 'Waiting on deposit',
                        state: _validated ? AkeaStepState.done : AkeaStepState.current,
                      ),
                      AkeaTrackerStep(
                        title: 'Converted to booking',
                        subtitle: 'Upcoming',
                        state: _validated ? AkeaStepState.current : AkeaStepState.upcoming,
                      ),
                      const AkeaTrackerStep(
                        title: 'Finalised quotation',
                        subtitle: 'Upcoming',
                        state: AkeaStepState.upcoming,
                      ),
                    ],
                  ),
                );
                if (stacked) {
                  return Column(children: [deposit, const SizedBox(height: 16), steps]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: deposit),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: steps),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
