// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:smartapp_project24/pages/events/allevents_page.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final List<CalendarEventData> events = [];

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    displayEvents(); // Call function to fetch events from Firestore
  }

  void displayEvents() async {
    db
        .collection(
            'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
        .get()
        .then(
      (QuerySnapshot querySnapshot) {
        setState(() {
          // Clear previous events
          events.clear();

          // Iterate over documents and add events to the list
          for (var doc in querySnapshot.docs) {
            events.add(
              CalendarEventData(
                date: (doc['startDate'] as Timestamp).toDate(),
                startTime: (doc['startTime'] as Timestamp).toDate(),
                endTime: (doc['endTime'] as Timestamp).toDate(),
                title: doc['title'] ?? '',
                description: doc['description'] ?? '',
                color: Color(
                  int.parse(
                    doc['color'].toRadixString(16),
                    radix: 16,
                  ),
                ),
                endDate: (doc['endDate'] as Timestamp).toDate(),
              ),
            );
          }
        });
      },
    ).catchError(
      (error) async {
        print('Failed to fetch events: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              color: Colors.lightBlue[100],
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: DateFormat('EEEE').format(
                        DateTime.now(),
                      ),
                      style: TextStyle(
                        color: Colors.lightBlue[800],
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n${DateFormat('d MMMM').format(
                            DateTime.now(),
                          )}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.lightBlue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      displayEvents();
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: Colors.lightBlue[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //? Classes grid view
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Classes',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightBlue[800],
                ),
              ),
            ),
            Container(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                children: [
                  lessonsCard(
                    'Frontend',
                    'Web Development',
                    Colors.lightBlue,
                  ),
                  lessonsCard(
                    'Smartapp',
                    'flutter project',
                    Colors.blue,
                  ),
                  lessonsCard(
                    'Backend',
                    'C# .NET',
                    Colors.deepPurple,
                  ),
                  lessonsCard(
                    'UI/UX',
                    'Interface Design',
                    Colors.deepOrange,
                  ),
                ],
              ),
            ),
            //? Events list view

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Row(
                children: [
                  Text(
                    'Planned Events',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.lightBlue[800],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllEventsPage(),
                          //settings: RouteSettings(arguments: events.toList()),
                        ),
                      );
                      print('View all events ' + events.length.toString());
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                        Colors.lightBlue[800],
                      ),
                    ),

                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: Colors.lightBlue[800],
                        fontSize: 16,
                      ),
                    ),
                    // style: ButtonStyle(
                    //   backgroundColor: MaterialStateProperty.all(
                    //     Colors.lightBlue[200],
                    //   ),
                    // ),
                  )
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 60,
                            color: Colors.lightBlue[800],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No events yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue[800],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: events.length > 3 ? 3 : events.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return ListTile(
                          title: Text(
                            event.title ?? 'My Event',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${DateFormat('hh:mm a').format(event.startTime!)} - ${DateFormat('hh:mm a').format(event.endTime!)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white70,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: event.color,
                            child: Text(
                              event.title.isNotEmpty
                                  ? event.title[0].toUpperCase()
                                  : 'E',
                              style: TextStyle(
                                color: event.color.computeLuminance() > 0.5
                                    ? Colors.black45
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: event.color.computeLuminance() > 0.5
                                ? Colors.black54
                                : Colors.white,
                            size: 20,
                          ),
                          tileColor: event.color.withOpacity(0.6),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailPage(event: event),
                              ),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  //!lessonsCard widget
  Widget lessonsCard(String className, String description, Color color) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              className,
              style: TextStyle(
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: color.computeLuminance() > 0.5
                    ? Colors.black54
                    : Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Add navigation logic here
                print('Navigating to $className');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(color),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
