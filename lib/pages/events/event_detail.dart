// ignore_for_file: prefer_const_constructors


import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/events/event_edit.dart';

class EventDetailPage extends StatelessWidget {
  final CalendarEventData event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: event.color,
        title: Text(
          'Event Details',
          style: TextStyle(
            color: event.color.computeLuminance() > 0.5
                ? Colors.black54
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: event.color.computeLuminance() > 0.5
                ? Colors.black54
                : Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Event Title:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.lightBlue[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              event.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Event Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.lightBlue[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              event.description!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Start Time:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.lightBlue[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat.yMMMMd().add_Hm().format(event.startTime!),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 50),
            Text(
              'End Time:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.lightBlue[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat.yMMMMd().add_Hm().format(event.endTime!),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventEditPage(event: event),
            ),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.edit),
      ),
    );
  }
}
