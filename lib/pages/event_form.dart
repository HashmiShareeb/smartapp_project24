import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({Key? key}) : super(key: key);

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(autocorrect: true,
            ),
            ElevatedButton(
              onPressed: () {
                final event = CalendarEventData(
                  date: DateTime.now(),
                  event: "Event 1",
                  title: 'event 1',
                  description: 'event 1 description',
                  startTime: DateTime(2024, 3, 30, 8),
                  endTime: DateTime(2024, 3, 30, 10),
                );
                CalendarControllerProvider.of(context).controller.add(event);
                //  final event = CalendarEventData(
                //   date: DateTime.now(),
                //   event: "Event 1",
                //   title: 'event 1',
                //   description: 'event 1 description',
                //   startTime: DateTime(2024, 3, 30, 8),
                //   endTime: DateTime(2024, 3, 30, 10),
                // );
                Navigator.pop(context); // Navigate back to the previous page
              },
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}
