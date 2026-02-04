import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/event_model.dart';
import '../providers/event_provider.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/event_list_widget.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  Future<void> _addEvent() async {
    if (_selectedDay == null) return;

    final newEvent = await showDialog<EventModel>(
      context: context,
      builder: (context) => AddEventDialog(selectedDate: _selectedDay!),
    );

    if (newEvent != null) {
      ref.read(eventsProvider.notifier).addEvent(newEvent);
    }
  }

  void _deleteEvent(String id) {
    ref.read(eventsProvider.notifier).deleteEvent(id);
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    final eventsMap = ref.watch(eventsMapProvider);
    return eventsMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final currentEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : <EventModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('My Calendar'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
      body: eventsAsync.when(
        data: (allEvents) {
          // Responsive Layout
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                // Desktop / Wide Tablet
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CalendarWidget(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        events: ref.watch(eventsMapProvider),
                        onDaySelected: _onDaySelected,
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Events for ${_selectedDay?.toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          Expanded(
                            child: EventListWidget(
                              events: currentEvents,
                              onDelete: _deleteEvent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile
                return Column(
                  children: [
                    CalendarWidget(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      events: ref.watch(eventsMapProvider),
                      onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: EventListWidget(
                        events: currentEvents,
                        onDelete: _deleteEvent,
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
