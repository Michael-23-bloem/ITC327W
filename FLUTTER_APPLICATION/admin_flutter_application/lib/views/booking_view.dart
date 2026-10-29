import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/order_viewmodel.dart';
import '../models/order.dart';

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
   void _openBookingDetails(Order order) {
  context.push('/quotations/${order.id}');
}
  /*void _openBookingDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    order.eventType,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.customerName ?? order.customerEmailOrId,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.calendar_today,
                    'Date',
                    '${order.eventDate.toLocal()}'.split(' ')[0],
                  ),
                  if (order.venue != null)
                    _detailRow(Icons.place_outlined, 'Venue', order.venue!),
                  _detailRow(Icons.group_outlined, 'Guests', '${order.guests}'),
                  _detailRow(Icons.flag_outlined, 'Status', order.status),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _detailRow(Icons.notes_outlined, 'Notes', order.notes!),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx); // close the popup
                        context.push('/bookings/${order.id}');
                      },
                      child: const Text('View more'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }*/

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final bookings = vm.bookings;
    // Show all bookings initially.
    final displayedBookings = _selectedDay == null
        ? bookings
        : _eventsForDay(_selectedDay!, bookings);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
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
                      final events = _eventsForDay(selectedDay, bookings);
                      if (events.length == 1) {
                        // single booking that day — open it directly
                        _openBookingDetails(events.first);
                      }
                    },
                    calendarStyle: const CalendarStyle(
                      markerDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: displayedBookings.isEmpty
                      ? Center(
                          child: Text(
                            _selectedDay == null
                                ? 'No active bookings yet.'
                                : 'No bookings on this date.',
                            style: const TextStyle(color: Colors.black45),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: displayedBookings.length,
                          itemBuilder: (_, i) {
                            final o = displayedBookings[i];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.event_available),
                                ),
                                title: Text(
                                  o.eventType,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${o.customerName ?? o.customerEmailOrId}\n'
                                  '${o.eventDate.toLocal().toString().split(' ')[0]}'
                                  ' • ${o.status}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _openBookingDetails(o),
                              ),
                            );
                          },
                        ),
                ),

                /*Expanded(
                  child: selectedDayEvents.isEmpty
                      ? const Center(
                          child: Text('No bookings yet', style: TextStyle(color: Colors.black45)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: selectedDayEvents.length,
                          itemBuilder: (_, i) {
                            final o = selectedDayEvents[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(o.eventType, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${o.customerName ?? o.customerEmailOrId} • ${o.status}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _openBookingDetails(o),
                              ),
                            );
                          },
                        ),
                ),*/
              ],
            ),
    );
  }
}
