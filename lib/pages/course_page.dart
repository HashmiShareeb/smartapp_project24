import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class CoursePage extends StatefulWidget {
  final CalendarEventData event;
  const CoursePage({super.key, required this.event});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<CalendarEventData> event = [
    CalendarEventData(
      title: 'Math',
      date: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 1)),
      color: Colors.blue,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Course'),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: event.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(event[index].title),
                subtitle: Text(
                  '${event[index].date} - ${event[index].endDate}',
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoursePage(event: event[index]),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
