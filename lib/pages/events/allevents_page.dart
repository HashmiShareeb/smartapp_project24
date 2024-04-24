import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<List<CalendarEventData>> events = [
    [
      CalendarEventData(
        title: 'Project meeting',
        description: 'Today is project meeting.',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        date: DateTime.now(),
        color: Colors.blue,
      ),
      CalendarEventData(
        title: 'Wedding anniversary',
        description: 'Attend uncle\'s wedding anniversary.',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        date: DateTime.now(),
        color: Colors.red,
      ),
      CalendarEventData(
        title: 'Football Tournament',
        description: 'Go to football tournament.',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        date: DateTime.now(),
        color: Colors.lime,
      ),
    ],
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Events '),
        //custom back button ios
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Column(
                  children: events[index]
                      .map(
                        (event) => ListTile(
                          title: Text(event.title),
                          subtitle: Text(event.description!),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailPage(event: event),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
