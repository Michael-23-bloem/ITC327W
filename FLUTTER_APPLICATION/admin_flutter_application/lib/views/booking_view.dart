import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/akea_ui.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderViewModel>().loadBookings();
    });
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Order> _eventsForDay(DateTime day, List<Order> allBookings) {
    final target = _normalize(day);
    return allBookings.where((o) => _normalize(o.eventDate) == target).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final bookings = vm.bookings;
    final selected = _selectedDay ?? _focusedDay;
    final selectedEvents = _eventsForDay(selected, bookings);

    return AkeaPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        children: [
          AkeaPageHeader(
            title: 'Bookings',
            subtitle: '${_monthName(_focusedDay)} ${_focusedDay.year}',
          ),
          if (vm.loading && bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 980;
                final calendar = AkeaCard(
                  child: TableCalendar<Order>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        _selectedDay != null && _normalize(day) == _normalize(_selectedDay!),
                    eventLoader: (day) => _eventsForDay(day, bookings),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focused) => setState(() => _focusedDay = focused),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(Icons.chevron_left),
                      rightChevronIcon: Icon(Icons.chevron_right),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: true,
                      todayDecoration: BoxDecoration(
                        color: AkeaColors.cream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      todayTextStyle: const TextStyle(color: AkeaColors.ink, fontWeight: FontWeight.w700),
                      selectedDecoration: BoxDecoration(
                        color: AkeaColors.purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      defaultDecoration: BoxDecoration(
                        color: AkeaColors.cream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      weekendDecoration: BoxDecoration(
                        color: AkeaColors.cream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      outsideDecoration: const BoxDecoration(color: Colors.transparent),
                      markerDecoration: const BoxDecoration(
                        color: AkeaColors.gold,
                        shape: BoxShape.circle,
                      ),
                      cellMargin: const EdgeInsets.all(6),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return const SizedBox.shrink();
                        final awaiting = events.any(
                          (e) =>
                              e.status == 'quotation_approved' ||
                              e.status.toLowerCase().contains('deposit'),
                        );
                        return Positioned(
                          bottom: 6,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: awaiting ? AkeaColors.gold : const Color(0xFF2F8A4A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
                final side = AkeaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(akeaWeekdayDate(selected), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      if (selectedEvents.isEmpty)
                        const Text('No bookings on this day.', style: TextStyle(color: AkeaColors.muted))
                      else
                        ...selectedEvents.map((o) => _DayBooking(order: o)),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          _LegendDot(color: Color(0xFF2F8A4A), label: 'Confirmed'),
                          SizedBox(width: 16),
                          _LegendDot(color: AkeaColors.gold, label: 'Awaiting deposit'),
                        ],
                      ),
                    ],
                  ),
                );
                if (stacked) {
                  return Column(children: [calendar, const SizedBox(height: 16), side]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: calendar),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: side),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  String _monthName(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[d.month - 1];
  }
}

class _DayBooking extends StatelessWidget {
  const _DayBooking({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final awaiting = order.status == 'quotation_approved' ||
        order.status.toLowerCase().contains('deposit');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AkeaColors.cream,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                AkeaStatusChip.forStatus(order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${order.eventType} · ${order.venue ?? 'Venue TBC'}',
              style: const TextStyle(color: AkeaColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Guests', style: TextStyle(color: AkeaColors.muted)),
                const Spacer(),
                Text('${order.guestCount}'),
              ],
            ),
            Row(
              children: [
                const Text('Estimated total', style: TextStyle(color: AkeaColors.muted)),
                const Spacer(),
                Text(akeaMoney(order.computedTotal)),
              ],
            ),
            const SizedBox(height: 12),
            AkeaButton(
              label: awaiting ? 'Confirm deposit' : 'Open booking',
              expand: true,
              onPressed: () => context.go(
                awaiting ? '/quotations/${order.id}/validate' : '/bookings/${order.id}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AkeaColors.muted)),
      ],
    );
  }
}
