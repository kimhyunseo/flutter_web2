import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventListWidget extends ConsumerWidget {
  final List<EventModel> events;
  final Function(String) onDelete;

  const EventListWidget({
    super.key,
    required this.events,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            '이벤트가 없습니다.\n+ 버튼을 눌러 추가해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Dismissible(
          key: Key(event.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(event.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: event.description != null
                  ? Text(event.description!)
                  : null,
              trailing: Text(
                DateFormat('yyyy-MM-dd').format(event.date),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              leading: Container(
                width: 4,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
