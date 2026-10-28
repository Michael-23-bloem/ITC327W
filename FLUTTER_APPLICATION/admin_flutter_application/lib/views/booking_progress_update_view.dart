import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/akea_ui.dart';

const _progressOptions = [
  'in_preparation',
  'setup',
  'completed',
];

String _labelFor(String status) {
  return switch (status) {
    'in_preparation' => 'In preparation',
    'setup' => 'Setup at venue',
    'completed' => 'Event completed',
    _ => status.replaceAll('_', ' '),
  };
}

class UpdateProgressView extends StatefulWidget {
  const UpdateProgressView({super.key, required this.orderId});
  final String orderId;

  @override
  State<UpdateProgressView> createState() => _UpdateProgressViewState();
}

class _UpdateProgressViewState extends State<UpdateProgressView> {
  final _note = TextEditingController();
  String _status = 'in_preparation';
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
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final o = vm.selected;
    if (o != null && _progressOptions.contains(o.status)) {
      _status = o.status;
    }

    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          AkeaPageHeader(
            title: 'Update progress${o == null ? '' : ': ${o.displayName}'}',
            subtitle: 'Shown on the client’s status tracker',
            actions: [
              AkeaButton(
                label: 'Save update',
                loading: _saving,
                onPressed: o == null
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await vm.updateProgress(widget.orderId, _status, _note.text);
                        if (context.mounted) context.go('/bookings/${widget.orderId}');
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
                final form = AkeaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      const AkeaFieldLabel('Booking'),
                      InputDecorator(
                        decoration: const InputDecoration(),
                        child: Text(
                          o == null
                              ? ''
                              : '${o.displayName} · ${o.eventType} · ${akeaDate(o.eventDate)}',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const AkeaFieldLabel('Progress status'),
                      DropdownButtonFormField<String>(
                        key: ValueKey(_status),
                        initialValue: _status,
                        items: _progressOptions
                            .map((s) => DropdownMenuItem(value: s, child: Text(_labelFor(s))))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v ?? _status),
                      ),
                      const SizedBox(height: 16),
                      const AkeaFieldLabel('Progress note (optional)'),
                      TextField(
                        controller: _note,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Add a short update for the client…',
                        ),
                      ),
                    ],
                  ),
                );
                final tracker = AkeaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client’s status tracker', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      ..._trackerFor(_status).map(
                        (s) => AkeaTrackerStep(title: s.$1, subtitle: s.$2, state: s.$3),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AkeaColors.cream,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'The client checks this themselves. No notification is sent.',
                          style: TextStyle(color: AkeaColors.muted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
                if (stacked) {
                  return Column(children: [form, const SizedBox(height: 16), tracker]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: form),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: tracker),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  List<(String, String, AkeaStepState)> _trackerFor(String status) {
    final stages = [
      ('Quotation confirmed', 'Completed'),
      ('Deposit validated', 'Completed'),
      ('In preparation', status == 'in_preparation' ? 'Current stage' : 'Completed'),
      ('Setup at venue', status == 'setup' ? 'Current stage' : 'Upcoming'),
      ('Event completed', status == 'completed' ? 'Current stage' : 'Upcoming'),
    ];
    AkeaStepState stateFor(int i) {
      if (status == 'completed') return i < 5 ? AkeaStepState.done : AkeaStepState.upcoming;
      if (status == 'setup') {
        if (i < 3) return AkeaStepState.done;
        if (i == 3) return AkeaStepState.current;
        return AkeaStepState.upcoming;
      }
      if (i < 2) return AkeaStepState.done;
      if (i == 2) return AkeaStepState.current;
      return AkeaStepState.upcoming;
    }

    return [
      for (var i = 0; i < stages.length; i++)
        (stages[i].$1, stages[i].$2, stateFor(i)),
    ];
  }
}
