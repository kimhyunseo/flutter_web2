import 'package:uuid/uuid.dart';

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String? description;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    this.description,
  });

  factory EventModel.create({
    required String title,
    required DateTime date,
    String? description,
  }) {
    return EventModel(
      id: const Uuid().v4(),
      title: title,
      date: date,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }
}
