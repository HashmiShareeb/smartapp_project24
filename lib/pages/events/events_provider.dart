// events_provider.dart or your provider file

import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class EventProvider extends ChangeNotifier {
  List<CalendarEventData> _events = [];

  List<CalendarEventData> get events => _events;

  void addEvent(CalendarEventData event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(CalendarEventData event) {
    // Update event logic

    events[events.indexWhere((e) => e.title == event.title)] = event;
    notifyListeners();
  }

  void deleteEvent(CalendarEventData event) {
    // Delete event logic
    notifyListeners();
  }

  Stream<List<CalendarEventData>> fetchEventsFromFirestore() {
    // Replace this with your actual Firestore logic
    return Stream.value(_events);
  }
}
