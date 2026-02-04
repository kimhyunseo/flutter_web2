import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents();
  Future<void> saveEvent(EventModel event);
  Future<void> deleteEvent(String id);
}

class EventRepositoryImpl implements EventRepository {
  static const String _storageKey = 'events_data';

  @override
  Future<List<EventModel>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => EventModel.fromJson(json)).toList();
  }

  @override
  Future<void> saveEvent(EventModel event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();

    // Update existing or add new
    final index = events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      events[index] = event;
    } else {
      events.add(event);
    }

    await _saveToPrefs(prefs, events);
  }

  @override
  Future<void> deleteEvent(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();

    events.removeWhere((e) => e.id == id);
    await _saveToPrefs(prefs, events);
  }

  Future<void> _saveToPrefs(
    SharedPreferences prefs,
    List<EventModel> events,
  ) async {
    final String data = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }
}
