import 'package:flutter/material.dart';

class Event {
  // final String id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String event;
  final String title;
  final String description;
  final DateTime date;
  final Color color;
  final DateTime endDate;

  // final String location; // Example of a custom property

  Event({
    // required this.id,
    required this.startTime,
    required this.endTime,
    required this.event,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
    required this.endDate,
    // required this.location,
  });

  static Event fromMap(Map<String, dynamic> data) {
    return Event(
      // id: data['id'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      event: data['event'],
      title: data['title'],
      description: data['description'],
      date: data['date'],
      color: Color(
        int.parse(
          data['color'].toRadixString(16),
          radix: 16,
        ),
      ),
      endDate: data['endDate'],

      // location: data['location'],
    );
  }
}
