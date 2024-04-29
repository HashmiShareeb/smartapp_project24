// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:smartapp_project24/pages/course_page.dart';
import 'package:smartapp_project24/pages/events/allevents_page.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<CalendarEventData> events = [];

  final List<CalendarEventData> hardcodedEvents = [
    CalendarEventData(
      title: 'Frontend Development',
      date: DateTime(DateTime.now().year, 4, 23),
      startTime: DateTime(DateTime.now().year, 4, 30, 8, 30),
      endTime: DateTime(DateTime.now().year, 4, 30, 12, 30),
      color: Colors.blue,
      event: 'React.js',
      description:
          'Learn how to build user interfaces with React.js and tailwindcss ',
    ),
    CalendarEventData(
      title: 'Backend Development',
      date: DateTime(DateTime.now().year, 4, 24),
      startTime: DateTime(DateTime.now().year, 4, 30, 13, 30),
      endTime: DateTime(DateTime.now().year, 4, 30, 18, 00),
      color: Colors.green,
      description: 'Learn how to build APIs with C# .NET',
    ),
    CalendarEventData(
      title: 'Smartapp Development',
      date: DateTime(DateTime.now().year, 4, 25),
      startTime: DateTime(DateTime.now().year, 4, 30, 13, 30),
      endTime: DateTime(DateTime.now().year, 4, 30, 17, 30),
      color: Colors.orange,
      description:
          'Flutter is a UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. Learn how to build apps with Flutter.',
    ),
    CalendarEventData(
      title: 'UI/UX Design',
      date: DateTime(DateTime.now().year, 4, 26),
      startTime: DateTime(DateTime.now().year, 4, 30, 13, 30),
      endTime: DateTime(DateTime.now().year, 4, 30, 17, 30),
      color: Colors.purple,
      description: 'Learn how to design user interfaces',
    ),
  ];

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
        .orderBy('startDate', descending: true)
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
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue[800],
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                children: [
                  for (int i = 0; i < hardcodedEvents.length; i++)
                    lessonsCard(
                      hardcodedEvents[i % hardcodedEvents.length].title,
                      hardcodedEvents[i % hardcodedEvents.length].description!,
                      hardcodedEvents[i % hardcodedEvents.length].color,
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
                    'Recent Events',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                      print('View all events ${events.length}');
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
                          const SizedBox(height: 10),
                          Text(
                            'No events yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.lightBlue[800],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Scrollbar(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: events.length > 2 ? 2 : events.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return ListTile(
                            title: Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: event.color.computeLuminance() > 0.5
                                    ? Colors.black54
                                    : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              '${event.startTime != null && event.endTime != null ? DateFormat('hh:mm a').format(event.startTime!) + ' - ' + DateFormat('hh:mm a').format(event.endTime!) : ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: event.color.computeLuminance() > 0.5
                                    ? Colors.black54
                                    : Colors.white70,
                              ),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: event.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  event.title.isNotEmpty
                                      ? event.title[0].toUpperCase()
                                      : 'E',
                                  style: TextStyle(
                                    color: event.color.computeLuminance() > 0.5
                                        ? Colors.black45
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
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
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                print('Navigating to $className');
                // Add navigation logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoursePage(
                      event: hardcodedEvents.firstWhere(
                        (element) => element.title == className,
                      ),
                    ),
                  ),
                );
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
