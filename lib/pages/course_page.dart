import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:smartapp_project24/main.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key}) : super(key: key);

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
          querySnapshot.docs.forEach((doc) {
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
          });
        });
      },
    ).catchError(
      (error) => print('Failed to fetch events: $error'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Container(
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
                          color: Colors.lightBlue[500],
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
                              color: Colors.lightBlue[500],
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
                        color: Colors.lightBlue[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Text(
                'Planned Events: ${events.length}',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightBlue[500],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: events.length,
                separatorBuilder: (context, index) => SizedBox(height: 10),
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    title: Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: event.color.computeLuminance() > 0.5
                            ? Colors.black12
                            : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${DateFormat('hh:mm a').format(event.startTime!)} - ${DateFormat('hh:mm a').format(event.endTime!)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: event.color,
                      child: Text(
                        event.title[0].toUpperCase(),
                        style: TextStyle(
                          color: event.color.computeLuminance() > 0.8
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: event.color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      size: 20,
                    ),
                    tileColor: event.color.withOpacity(0.6),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(event: event),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Classes',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightBlue[500],
                ),
              ),
            ),
            Container(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                children: [
                  lessonsCard('Frontend', Colors.lightBlue),
                  lessonsCard('Smartapp', Colors.lightBlue),
                  lessonsCard('Backend', Colors.lightBlue),
                  lessonsCard('UI/UX', Colors.lightBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lessonsCard(String className, Color color) {
    return GestureDetector(
      onTap: () {
        // Add navigation logic here
        print('Navigating to $className');
      },
      child: Container(
        width: 260,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            className,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
