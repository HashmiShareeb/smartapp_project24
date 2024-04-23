// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartapp_project24/firebase_options.dart';
import 'package:smartapp_project24/pages/auth/login_page.dart';

DateTime get _now => DateTime.now();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final fetchedEvents = await fetchEventsFromFirestore();
  final events = fetchedEvents[0]; // Events from Firestore
  final hardcodedEvents = fetchedEvents[1]; // Hardcoded Events

  runApp(MainApp(events: events, hardcodedEvents: hardcodedEvents));
}

class MainApp extends StatelessWidget {
  final List<CalendarEventData> events;
  final List<CalendarEventData> hardcodedEvents;

  const MainApp({Key? key, required this.events, required this.hardcodedEvents})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CalendarEventData>>(
      stream: listenForEventsFromFirestore(),
      builder: (context, snapshot) {
        // Building UI based on snapshot state
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData) {
          // If data is available, combine Firestore events with hardcoded events
          final firestoreEvents = snapshot.data!;
          final allEvents = [
            ...firestoreEvents,
            ...hardcodedEvents
          ]; // Combine events

          // Return MaterialApp with CalendarControllerProvider
          return CalendarControllerProvider(
            controller: EventController()..addAll(allEvents),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  headerHelpStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  confirmButtonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.orange, // 30% Accent - Button background,
                    ),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                scaffoldBackgroundColor: Colors.grey[100],
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.lightBlue[800],
                  titleTextStyle: TextStyle(
                    color: Colors.lightBlue[50],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  iconTheme: IconThemeData(
                    color: Colors.lightBlue[50],
                    size: 20,
                  ),
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor:
                      Colors.orange, // 30% Accent - Button background
                ),
                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: Colors.white,
                  indicatorColor: Colors.lightBlue[100],
                  labelTextStyle: MaterialStateProperty.all(
                    TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  iconTheme: MaterialStateProperty.all(
                    IconThemeData(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              title: 'SmartApp Project24',
              scrollBehavior: const ScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
              ),
              home: LoginPage(), // Initial page is LoginPage
            ),
          );
        }

        return CircularProgressIndicator(); // Show loading indicator initially
      },
    );
  }
}

Stream<List<CalendarEventData>> listenForEventsFromFirestore() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value([]); // Return an empty list if user is not logged in
  }

  final eventsCollection = FirebaseFirestore.instance.collection(
      'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');

  return eventsCollection.snapshots().map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return CalendarEventData(
        date: data['startDate'].toDate(),
        startTime: data['startTime'].toDate(),
        endTime: data['endTime'].toDate(),
        title: data['title'],
        description: data['description'],
        endDate: data['endDate'].toDate(),
      );
    }).toList();
  });
}

Future<List<List<CalendarEventData>>> fetchEventsFromFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return [[], _events]; // Return empty events if user is not logged in
  }

  // Fetch events from Firestore collection
  final fetchedEvents = await FirebaseFirestore.instance
      .collection('project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
      .get()
      .then((querySnapshot) {
    final events = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return CalendarEventData(
        date: data['startDate'].toDate(),
        startTime: data['startTime'].toDate(),
        endTime: data['endTime'].toDate(),
        title: data['title'],
        description: data['description'],
        endDate: data['endDate'].toDate(),
      );
    }).toList();

    return [events, _events]; // Return Firestore events and hardcoded events
  }).catchError((error) {
    return Future<List<List<CalendarEventData<Object?>>>>.value(
        [[], _events]); // Return empty events if fetch fails
  });

  return fetchedEvents;
}

// Define your custom eventFilter function
Future<bool> yourEventFilterFunction<T>(CalendarEventData<T> event) async {
  // Implement your logic here
  // Return true to include the event or false to exclude it

  return true;
}

// Define your custom eventSorter function
Future<int> yourEventSorterFunction<T>(
  CalendarEventData<T> event1,
  CalendarEventData<T> event2,
) async {
  // Implement your logic here
  // Return a negative value if event1 should come before event2,
  // a positive value if event1 should come after event2,
  // or zero if they are considered equal
  return 0;
}

// Hardcoded events
List<CalendarEventData> _events = [
  CalendarEventData(
    date: DateTime(2024, 4, 22),
    title: "Frontend Development",
    description: "nextjs and tailwindcss",
    startTime: DateTime(_now.year, _now.month, _now.day, 10, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 12, 45),
    // endDate: DateTime(2024, 4, 25),
  ),
  CalendarEventData(
    date: DateTime(2024, 4, 23),
    startTime: DateTime(_now.year, _now.month, _now.day, 10, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 12, 30),
    title: "SmartApp Development",
    description: "Flutter and Firebase intergrations.",
  ),
  CalendarEventData(
    date: DateTime(2024, 4, 24),
    startTime: DateTime(_now.year, _now.month, _now.day, 8, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 12, 30),
    title: "Frontend Development",
    description: "Labo nextjs",
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 3)),
    startTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 10),
    endTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 14),
    title: "UI/UX Design",
    description: "Figma and Adobe XD",
  ),
];
