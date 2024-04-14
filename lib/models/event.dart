import 'package:flutter/material.dart';

class Event {
  final String id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String event;
  final String title;
  final String description;

  final DateTime date;
  // final String location; // Example of a custom property

  Event({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.event,
    required this.title,
    required this.description,
    required this.date,
    // required this.location,
  });
}
