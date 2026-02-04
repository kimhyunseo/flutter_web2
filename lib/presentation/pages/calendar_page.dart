import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      body: eventsAsync.when(
        data: (allEvents) {
          return SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Custom Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Calendar',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  today,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            FloatingActionButton.extended(
                              onPressed: _addEvent,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'New Event',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              elevation: 4,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 900) {
                              // Desktop Layout
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: SingleChildScrollView(
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
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        border: Border(
                                          left: BorderSide(
                                            color: theme.dividerColor
                                                .withValues(alpha: 0.1),
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Text(
                                              _selectedDay == null
                                                  ? 'Events'
                                                  : DateFormat(
                                                      'd MMMM yyyy',
                                                    ).format(_selectedDay!),
                                              style: theme
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                  ),
                                ],
                              );
                            } else {
                              // Mobile Layout
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
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(32),
                                            ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, -5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              24,
                                              24,
                                              24,
                                              8,
                                            ),
                                            child: Text(
                                              _selectedDay == null
                                                  ? 'Events'
                                                  : DateFormat(
                                                      'd MMMM yyyy',
                                                    ).format(_selectedDay!),
                                              style: theme
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
