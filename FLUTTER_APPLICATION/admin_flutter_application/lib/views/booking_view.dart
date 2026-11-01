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
  String _selectedFilter = 'all';

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

  Color _statusColor(String status) {
    switch (status) {
      case 'deposit_received':
        return const Color(0xFF2F8A4A); // Green
      case 'preparations_begin':
        return AkeaColors.gold; // Yellow
      case 'completed':
        return const Color(0xFF477DB5); // Blue
      case 'cancelled':
      case 'declined':
        return const Color(0xFFC65353); // Red
      default:
        return AkeaColors.muted;
    }
  }

  Color _dayBackground(List<Order> events) {
    if (events.any((e) => e.status == 'preparations_begin')) {
      return AkeaColors.gold.withValues(alpha: 0.25);
    }

    if (events.any((e) => e.status == 'deposit_received')) {
      return const Color(0xFF2F8A4A).withValues(alpha: 0.20);
    }

    if (events.any((e) => e.status == 'completed')) {
      return const Color(0xFF477DB5).withValues(alpha: 0.18);
    }

    if (events.any((e) => e.status == 'cancelled' || e.status == 'declined')) {
      return const Color(0xFFC65353).withValues(alpha: 0.18);
    }

    return AkeaColors.cream;
  }

  Widget _buildCalendarDay(
    DateTime date,
    List<Order> events, {
    bool selected = false,
    bool today = false,
    bool outside = false,
  }) {
    final hasEvents = events.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: hasEvents
            ? _dayBackground(events)
            : (outside ? Colors.transparent : AkeaColors.cream),
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: AkeaColors.purple, width: 2)
            : today
            ? Border.all(color: AkeaColors.gold, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              color: outside ? AkeaColors.muted : AkeaColors.ink,
              fontWeight: selected || hasEvents
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          if (hasEvents)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: events
                  .map(
                    (event) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _statusColor(event.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                  .take(3)
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingFilter() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filter bookings',
      initialValue: _selectedFilter,
      onSelected: (value) {
        setState(() {
          _selectedFilter = value;
        });
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'all', child: Text('All bookings')),
        PopupMenuItem(
          value: 'deposit_received',
          child: Text('Deposit received'),
        ),
        PopupMenuItem(
          value: 'preparations_begin',
          child: Text('In preparation'),
        ),
        PopupMenuItem(value: 'completed', child: Text('Completed')),
        PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final bookings = vm.bookings;
    // First filter by selected calendar date.
final dateFilteredBookings = _selectedDay == null
    ? bookings
    : _eventsForDay(_selectedDay!, bookings);

// Then apply the existing status filter.
final filteredBookings = _selectedFilter == 'all'
    ? dateFilteredBookings
    : dateFilteredBookings
        .where((order) => order.status == _selectedFilter)
        .toList();
    ///final selected = _selectedDay ?? _focusedDay;
    //final selectedEvents = _eventsForDay(selected, bookings);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F1E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF51483F)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: AkeaPageHeader(
          title: 'Bookings',
          subtitle: '${_monthName(_focusedDay)} ${_focusedDay.year}',
        ),
      ),

      body: AkeaPage(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
          children: [
            if (vm.loading && bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  //final stacked = constraints.maxWidth < 980;
                  final calendar = AkeaCard(
                    child: TableCalendar<Order>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          _selectedDay != null &&
                          _normalize(day) == _normalize(_selectedDay!),
                      eventLoader: (day) => _eventsForDay(day, bookings),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focused) =>
                          setState(() => _focusedDay = focused),
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.chevron_left),
                        rightChevronIcon: Icon(Icons.chevron_right),
                      ),

                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: true,
                        cellMargin: EdgeInsets.zero,
                      ),

                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, focusedDay) {
                          final events = _eventsForDay(date, bookings);

                          return _buildCalendarDay(date, events);
                        },

                        selectedBuilder: (context, date, focusedDay) {
                          final events = _eventsForDay(date, bookings);

                          return _buildCalendarDay(
                            date,
                            events,
                            selected: true,
                          );
                        },

                        todayBuilder: (context, date, focusedDay) {
                          final events = _eventsForDay(date, bookings);

                          return _buildCalendarDay(date, events, today: true);
                        },

                        outsideBuilder: (context, date, focusedDay) {
                          final events = _eventsForDay(date, bookings);

                          return _buildCalendarDay(date, events, outside: true);
                        },
                      ),
                     /* calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return const SizedBox.shrink();
                          /*final awaiting = events.any(
                            (e) =>
                                e.status == 'quotation_approved' ||
                                e.status.toLowerCase().contains('deposit'),
                          );*/
                          final awaiting = events.any(
                            (e) => e.status == 'quotation_approved',
                          );
                          return Positioned(
                            bottom: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: awaiting
                                    ? AkeaColors.gold
                                    : const Color(0xFF2F8A4A),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),*/
                    ),
                  );
                  /* final side = AkeaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        akeaWeekdayDate(selected),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (selectedEvents.isEmpty)
                        const Text(
                          'No bookings on this day.',
                          style: TextStyle(color: AkeaColors.muted),
                        )
                      else
                        ...selectedEvents.map((o) => _DayBooking(order: o)),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          _LegendDot(
                            color: Color(0xFF2F8A4A),
                            label: 'Confirmed',
                          ),
                          SizedBox(width: 16),
                          _LegendDot(
                            color: AkeaColors.gold,
                            label: 'Awaiting deposit',
                          ),
                        ],
                      ),
                    ],
                  ),
                );*/

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      calendar,
                      const SizedBox(height: 16),

                      Row(
  children: [
    Expanded(
      child: Text(
        _selectedDay == null
            ? 'All bookings'
            : 'Bookings for ${_selectedDay!.day} '
                '${_monthName(_selectedDay!)}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    if (_selectedDay != null)
      TextButton(
        onPressed: () {
          setState(() {
            _selectedDay = null;
          });
        },
        child: const Text('Show all'),
      ),

    _buildBookingFilter(),
  ],
),

                      const SizedBox(height: 12),

                      _AllBookings(bookings: filteredBookings),
                    ],
                  );
                  /*return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [calendar, 
                  const SizedBox(height: 20), 

                  _AllBookings(bookings: bookings),
                  ],
                );*/
                  /*if (stacked) {
                  return Column(children: [calendar, const SizedBox(height: 16), side]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: calendar),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: side),
                  ],
                );*/
                },
              ),
          ],
        ),
      ),
    );
  }

  String _monthName(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[d.month - 1];
  }
}

class _DayBooking extends StatelessWidget {
  const _DayBooking({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    /* final awaiting =
        order.status == 'quotation_approved' ||
        order.status.toLowerCase().contains('deposit');*/
    final isPreparing = order.status == 'preparations_begin';
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
                  child: Text(
                    order.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
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
                const Text(
                  'Estimated total',
                  style: TextStyle(color: AkeaColors.muted),
                ),
                const Spacer(),
                Text(akeaMoney(order.computedTotal)),
              ],
            ),
            const SizedBox(height: 12),
            AkeaButton(
              label: isPreparing ? 'Open booking' : 'View booking',
              expand: true,
              onPressed: () => context.go('/bookings/${order.id}'),
            ),
            /*AkeaButton(
              label: awaiting ? 'Confirm deposit' : 'Open booking',
              expand: true,
              onPressed: () => context.go(
                awaiting
                    ? '/quotations/${order.id}/validate'
                    : '/bookings/${order.id}',
              ),
            ),*/
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
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AkeaColors.muted),
        ),
      ],
    );
  }
}

// Keep this class separate from _LegendDot.

class _AllBookings extends StatelessWidget {
  final List<Order> bookings;

  const _AllBookings({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No active bookings yet.',
            style: TextStyle(color: AkeaColors.muted, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = bookings[index];

        return Material(
          color: AkeaColors.cream,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              context.go('/bookings/${order.id}');
            },
            /* onTap: () {
              context.go('/quotations/${order.id}');
            },*/
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.eventType} · ${order.venue ?? 'Venue TBC'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AkeaColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AkeaStatusChip.forStatus(order.status),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AkeaColors.muted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/*class _AllBookings extends StatelessWidget {
  const _AllBookings({required this.bookings});

  final List<Order> bookings;

  @override
  Widget build(BuildContext context) {
    final allBookings = [...bookings]
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

    if (allBookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No quotations available.',
            style: TextStyle(color: AkeaColors.muted),
          ),
        ),
      );
    }

    return Column(
      children: allBookings.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: AkeaColors.cream,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                context.go('/quotations/${order.id}');
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.eventType} · ${order.venue ?? 'Venue TBC'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AkeaColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AkeaStatusChip.forStatus(order.status),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AkeaColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
*/
