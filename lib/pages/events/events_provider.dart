import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';

final EventsProvider eventsProvider = EventsProvider();

class EventsProvider extends ChangeNotifier {
  final List<CalendarEventData> _events = [];

  List<CalendarEventData> get events => _events;

  void addEvent(CalendarEventData event) {
    _events.add(event);
    notifyListeners(); // Notify listeners of the change
  }

  // Add methods for updating and deleting events (optional)
  void updateEvent(int index, CalendarEventData updatedEvent) {
    if (index >= 0 && index < _events.length) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void deleteEvent(int index) {
    if (index >= 0 && index < _events.length) {
      _events.removeAt(index);
      notifyListeners();
    }
  }
}
