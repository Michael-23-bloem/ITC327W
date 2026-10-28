
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/order_viewmodel.dart';
import '../../models/order_status.dart';

class _Palette {
  static const background = Color(0xFFF7F4EF);
  static const ink = Color(0xFF2B2621);
  static const muted = Color(0xFF82766A);
  static const gold = Color(0xFFCE9448);
  static const goldLight = Color(0xFFF5E9D6);
  static const card = Colors.white;
  static const border = Color(0xFFECE5DB);
  static const success = Color(0xFF4C7A5E);
  static const danger = Color(0xFFB4533D);
}

class UpdateProgressView extends StatefulWidget {
  final String orderId;

  const UpdateProgressView({
    super.key,
    required this.orderId,
  });

  @override
  State<UpdateProgressView> createState() =>
      _UpdateProgressViewState();
}

class _UpdateProgressViewState extends State<UpdateProgressView> {
  late String status;
  bool _saving = false;

  static const _terminal = [
    OrderStatus.completed,
    OrderStatus.declined,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();

    final current =
        context.read<OrderViewModel>().selected?.status;

    status = OrderStatus.all.contains(current)
        ? current!
        : OrderStatus.requestSent;
  }

  Color _statusColor(String value) {
    switch (value) {
      case OrderStatus.requestSent:
        return const Color(0xFF3976B8);
      case OrderStatus.inContact:
        return const Color(0xFFB7791F);
      case OrderStatus.quotationApproved:
        return const Color(0xFF278568);
      case OrderStatus.orderConfirmed:
        return const Color(0xFF6B59A3);
      case OrderStatus.depositReceived:
        return const Color(0xFF287D78);
      case OrderStatus.preparationsBegin:
        return const Color(0xFFD97736);
      case OrderStatus.completed:
        return _Palette.success;
      case OrderStatus.declined:
      case OrderStatus.cancelled:
        return _Palette.danger;
      default:
        return _Palette.muted;
    }
  }

  Future<void> _showPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _Palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Icon(icon, color: iconColor, size: 46),
        title: Text(
          title,
          style: const TextStyle(
            color: _Palette.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _Palette.muted),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Palette.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      // Empty note: this page updates status only.
      await context
          .read<OrderViewModel>()
          .updateProgress(widget.orderId, status, '');

      if (!mounted) return;

      await _showPopup(
        title: 'Progress updated',
        message:
            'The order status is now "${OrderStatus.label(status)}".',
        icon: Icons.check_circle_outline,
        iconColor: _Palette.success,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      await _showPopup(
        title: 'Update failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline,
        iconColor: _Palette.danger,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderViewModel>().selected;
    final isTerminal = _terminal.contains(status);

    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: AppBar(
        backgroundColor: _Palette.background,
        foregroundColor: _Palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Update progress',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _pageHeader(),
            const SizedBox(height: 20),

            if (order != null) ...[
              _orderSummary(order),
              const SizedBox(height: 28),
            ],

            _sectionHeading(
              'Order timeline',
              'Select the stage you want to move this order to.',
            ),
            const SizedBox(height: 18),

            _timeline(),

            const SizedBox(height: 24),

            Row(
              children: const [
                Expanded(
                  child: Divider(color: _Palette.border),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ORDER CLOSURE',
                    style: TextStyle(
                      color: _Palette.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: _Palette.border),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _terminalOptions(),

            if (isTerminal) ...[
              const SizedBox(height: 14),
              _closureWarning(status),
            ],

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _Palette.goldLight.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _Palette.gold.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _Palette.gold,
                    size: 21,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This updates the order status in the system. '
                      'Contact the client separately; WhatsApp '
                      'integration can be added to this workflow later.',
                      style: TextStyle(
                        color: _Palette.ink,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: _Palette.card,
            border: const Border(
              top: BorderSide(color: _Palette.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.ink,
                    side: const BorderSide(
                      color: _Palette.border,
                    ),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _saving ? 'Saving...' : 'Update progress',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Palette.gold,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _Palette.gold.withValues(alpha: 0.5),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF342D26),
            Color(0xFF554435),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.route_outlined,
              color: Color(0xFFE6BC7E),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR WORKSPACE',
                  style: TextStyle(
                    color: Color(0xFFE6BC7E),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage order progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep every event moving forward.',
                  style: TextStyle(
                    color: Color(0xFFD8CDC0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _Palette.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _Palette.muted,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _orderSummary(dynamic order) {
    final eventDate = order.eventDate;

    final dateText =
        '${eventDate.day.toString().padLeft(2, '0')}/'
        '${eventDate.month.toString().padLeft(2, '0')}/'
        '${eventDate.year}';

    final customer = order.customerName ??
        order.customerEmail ??
        order.customerEmailOrId;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.border),
        boxShadow: [
          BoxShadow(
            color: _Palette.ink.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _Palette.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.celebration_outlined,
                  color: _Palette.gold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.eventType ?? 'Event',
                      style: const TextStyle(
                        color: _Palette.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer ?? 'Customer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _Palette.muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: _Palette.border, height: 1),
          ),
          _summaryDetail(
            Icons.calendar_today_outlined,
            'Event date',
            dateText,
          ),
          const SizedBox(height: 12),
          _summaryDetail(
            Icons.location_on_outlined,
            'Venue',
            (order.venue?.toString().trim().isNotEmpty ?? false)
                ? order.venue.toString()
                : 'Not specified',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _statusColor(order.status).withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _statusColor(order.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Current status: ${OrderStatus.label(order.status)}',
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDetail(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: _Palette.gold, size: 17),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(
            color: _Palette.muted,
            fontSize: 12.5,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _Palette.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeline() {
    final steps = OrderStatus.steps;
    final currentIndex = steps.indexOf(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.border),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final value = steps[i];
          final isDone = currentIndex > i;
          final isCurrent = value == status;
          final isLast = i == steps.length - 1;

          final dotColor = isDone || isCurrent
              ? _Palette.gold
              : const Color(0xFFE5DED4);

          return InkWell(
            onTap: _saving
                ? null
                : () => setState(() => status = value),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Column(
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              border: isCurrent
                                  ? Border.all(
                                      color: const Color(0xFFE9D3B0),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isDone
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  )
                                : isCurrent
                                    ? const Icon(
                                        Icons.circle,
                                        color: Colors.white,
                                        size: 8,
                                      )
                                    : null,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                constraints: const BoxConstraints(
                                  minHeight: 25,
                                ),
                                color: isDone
                                    ? _Palette.gold.withValues(alpha: 0.5)
                                    : _Palette.border,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? _Palette.goldLight
                              : _Palette.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? _Palette.gold.withValues(alpha: 0.65)
                                : _Palette.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                OrderStatus.label(value),
                                style: TextStyle(
                                  color: _Palette.ink,
                                  fontSize: 13,
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              const Icon(
                                Icons.check_circle,
                                color: _Palette.gold,
                                size: 19,
                              )
                            else if (isDone)
                              const Icon(
                                Icons.check_circle_outline,
                                color: _Palette.success,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _terminalOptions() {
    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: _terminal.map((value) {
        final selected = value == status;
        final color = value == OrderStatus.completed
            ? _Palette.success
            : _Palette.danger;

        return ChoiceChip(
          label: Text(OrderStatus.label(value)),
          selected: selected,
          onSelected: _saving
              ? null
              : (_) => setState(() => status = value),
          showCheckmark: false,
          avatar: Icon(
            value == OrderStatus.completed
                ? Icons.check_circle_outline
                : value == OrderStatus.declined
                    ? Icons.block_outlined
                    : Icons.cancel_outlined,
            color: selected ? Colors.white : color,
            size: 17,
          ),
          labelStyle: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          backgroundColor: _Palette.card,
          selectedColor: color,
          side: BorderSide(
            color: color.withValues(alpha: 0.4),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }

  Widget _closureWarning(String value) {
    final completed = value == OrderStatus.completed;
    final color = completed ? _Palette.success : _Palette.danger;

    final message = completed
        ? 'This marks the order as completed.'
        : value == OrderStatus.declined
            ? 'This marks the request as declined.'
            : 'This marks the order as cancelled.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _Palette.ink,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/order_status.dart';

// Palette shared with the rest of the admin app, plus warm,
// non-generic success/danger tones instead of Material's defaults.
class _Palette {
  static const ink = Color(0xFF2B2621);
  static const muted = Color(0xFF8A8178);
  static const gold = Color(0xFFCE9448);
  static const warmGrey = Color(0xFFBDBAB5);
  static const card = Color(0xFFF7F6F3);
  static const field = Color(0xFFECECEC);
  static const success = Color(0xFF4C7A5E);
  static const danger = Color(0xFFB4533D);
}

class UpdateProgressView extends StatefulWidget {
  final String orderId;
  const UpdateProgressView({super.key, required this.orderId});

  @override
  State<UpdateProgressView> createState() => _UpdateProgressViewState();
}

class _UpdateProgressViewState extends State<UpdateProgressView> {
  final _note = TextEditingController();
  late String status;
  bool _saving = false;

  static const _terminal = [
    OrderStatus.completed,
    OrderStatus.declined,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();

    final current = context.read<OrderViewModel>().selected?.status;

    status = OrderStatus.all.contains(current)
        ? current!
        : OrderStatus.requestSent;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _showPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(icon, color: iconColor, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Palette.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await context
          .read<OrderViewModel>()
          .updateProgress(widget.orderId, status, _note.text.trim());

      if (!mounted) return;

      await _showPopup(
        title: 'Progress updated',
        message:
            'The order status is now "${OrderStatus.label(status)}".',
        icon: Icons.check_circle_outline,
        iconColor: _Palette.success,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      await _showPopup(
        title: 'Update failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline,
        iconColor: _Palette.danger,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderViewModel>().selected;
    final isTerminal = _terminal.contains(status);

    return Scaffold(
      backgroundColor: _Palette.warmGrey,
      appBar: AppBar(
        title: const Text('Update progress'),
        backgroundColor: _Palette.warmGrey,
        foregroundColor: _Palette.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            if (order != null) _orderSummary(order),
            const SizedBox(height: 24),

            const Text(
              'Where is this order?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _Palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap a stage to move the order there.',
              style: TextStyle(fontSize: 13, color: _Palette.muted),
            ),
            const SizedBox(height: 18),

            _timeline(),

            const SizedBox(height: 28),
            Row(
              children: const [
                Expanded(child: Divider(color: _Palette.field, thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'or close it out',
                    style: TextStyle(fontSize: 12, color: _Palette.muted),
                  ),
                ),
                Expanded(child: Divider(color: _Palette.field, thickness: 1)),
              ],
            ),
            const SizedBox(height: 14),
            _terminalChips(),

            const SizedBox(height: 28),
            const Text(
              'Note',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _Palette.ink,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _Palette.field),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: TextField(
                controller: _note,
                enabled: !_saving,
                maxLines: 3,
                style: const TextStyle(color: _Palette.ink),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'What changed, or what the client should know',
                  hintStyle: TextStyle(color: _Palette.muted, fontSize: 13),
                ),
              ),
            ),

            if (isTerminal) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _Palette.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: _Palette.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Setting "${OrderStatus.label(status)}" takes this order '
                        'off the active list.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _Palette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.gold,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _Palette.gold.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderSummary(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _Palette.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_outlined, color: _Palette.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.eventType ?? 'Event',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _Palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.customerName ?? order.customerEmailOrId ?? '',
                  style: const TextStyle(fontSize: 13, color: _Palette.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeline() {
    final steps = OrderStatus.steps;
    final currentIndex = steps.contains(status) ? steps.indexOf(status) : -1;

    return Column(
      children: List.generate(steps.length, (i) {
        final value = steps[i];
        final isDone = currentIndex != -1 && i < currentIndex;
        final isCurrent = value == status;
        final isLast = i == steps.length - 1;

        final dotColor = isCurrent
            ? _Palette.gold
            : isDone
                ? _Palette.gold.withValues(alpha: 0.5)
                : _Palette.field;

        return InkWell(
          onTap: _saving ? null : () => setState(() => status = value),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: isCurrent
                              ? Border.all(color: _Palette.gold, width: 2)
                              : null,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: isDone
                                ? _Palette.gold.withValues(alpha: 0.4)
                                : _Palette.field,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        OrderStatus.label(value),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? _Palette.ink : _Palette.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _terminalChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _terminal.map((value) {
        final selected = value == status;
        final color =
            value == OrderStatus.completed ? _Palette.success : _Palette.danger;

        return ChoiceChip(
          label: Text(OrderStatus.label(value)),
          selected: selected,
          onSelected: _saving ? null : (_) => setState(() => status = value),
          showCheckmark: false,
          labelStyle: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          backgroundColor: Colors.white,
          selectedColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        );
      }).toList(),
    );
  }
}*/