import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository_impl.dart';

// Repository Provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl();
});

// Events State Notifier
final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<EventModel>>(
  () {
    return EventsNotifier();
  },
);

class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  late final EventRepository _repository;

  @override
  Future<List<EventModel>> build() async {
    _repository = ref.watch(eventRepositoryProvider);
    return _repository.getEvents();
  }

  Future<void> addEvent(EventModel event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveEvent(event);
      return _repository.getEvents();
    });
  }

  Future<void> deleteEvent(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteEvent(id);
      return _repository.getEvents();
    });
  }
}

// LinkedHashMap Provider for TableCalendar efficiency
final eventsMapProvider = Provider<LinkedHashMap<DateTime, List<EventModel>>>((
  ref,
) {
  final eventsAsync = ref.watch(eventsProvider);

  return eventsAsync.maybeWhen(
    data: (events) {
      return LinkedHashMap<DateTime, List<EventModel>>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(_groupEventsByDate(events));
    },
    orElse: () => LinkedHashMap<DateTime, List<EventModel>>(
      equals: isSameDay,
      hashCode: getHashCode,
    ),
  );
});

Map<DateTime, List<EventModel>> _groupEventsByDate(List<EventModel> events) {
  final Map<DateTime, List<EventModel>> data = {};
  for (final event in events) {
    final date = DateTime(event.date.year, event.date.month, event.date.day);
    if (data[date] == null) data[date] = [];
    data[date]!.add(event);
  }
  return data;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
