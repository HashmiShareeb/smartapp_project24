import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';
import 'package:collection/collection.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final db = FirebaseFirestore.instance;
  List<List<CalendarEventData>> events = [[]];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    displayAllEvents();
  }

  void displayAllEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await db
        .collection('project_sm/${user!.uid}/events')
        .orderBy('startDate')
        .get();
    final fetchedEvents = snapshot.docs.map(
      (doc) => CalendarEventData(
        title: doc['title'],
        description: doc['description'],
        date: doc['startDate'].toDate(),
        endDate: doc['endDate'].toDate(),
        color: Color(doc['color']),
        startTime: doc['startTime'].toDate(),
        endTime: doc['endTime'].toDate(),
      ),
    );

    final groupedEvents = groupBy(
      fetchedEvents,
      (CalendarEventData event) => event.date,
    );

    setState(() {
      events = groupedEvents.values.toList();
    });
  }

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
                          title: Text(
                            event.title,
                            style: TextStyle(
                              //event color white if dark and black if light
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Text(
                            event.description!,
                            style: TextStyle(
                              //event color white if dark and black if light
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: event.color,
                            child: Text(
                              event.title[0].toUpperCase(),
                              style: TextStyle(
                                color: event.color.computeLuminance() > 0.5
                                    ? Colors.black54
                                    : Colors.white,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          tileColor: event.color.withOpacity(0.8),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
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
