import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final CalendarEventData event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Event Title: ${event.title}'),
            Text('Event Description: ${event.description ?? ""}'),

            ElevatedButton(
              onPressed: () {
                // Delete event
                CalendarControllerProvider.of(context).controller.remove(event);
                Navigator.of(context).pop();
              },
              child: const Text('Delete Event'),
            ),
            // Other event details
          ],
          //edit event button
        ),
        //delete event button
      ),
    );
  }
}
