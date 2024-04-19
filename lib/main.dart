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

  final events = await fetchEventsFromFirestore();
  runApp(MainApp(events: events));
}

class MainApp extends StatelessWidget {
  final List<CalendarEventData> events;
  const MainApp({super.key, required this.events});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()..addAll(events),
      child: MaterialApp(
        themeAnimationCurve: Curves.easeInOutCubic,
        //navigation theme
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
            backgroundColor: Colors.orange, // 30% Accent - Button background
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
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
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
        ),

        debugShowCheckedModeBanner: false,
        scrollBehavior: const ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        home: LoginPage(),
      ),
    );
  }
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

//hardcoded events
List<CalendarEventData> _events = [
  CalendarEventData(
    date: _now,
    startTime: DateTime(_now.year, 4, 16, 10, 45),
    endTime: DateTime(_now.year, 4, 16, 12, 45),
    title: "Frontend Development",
    description: "Theorie Next.js and tailwindcss",
  ),
  CalendarEventData(
    date: _now,
    startTime: DateTime(_now.year, 4, 16, 13, 45),
    endTime: DateTime(_now.year, 4, 16, 17, 45),
    title: "SmartApp Development",
    description: "flutter and firebase",
  ),
];

Future<List<CalendarEventData>> fetchEventsFromFirestore() async {
  if (FirebaseAuth.instance.currentUser == null) {
    return _events;
  }
  final eventsCollection = FirebaseFirestore.instance.collection(
      'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');

  final querySnapshot = await eventsCollection.get();

  final events = querySnapshot.docs.map((doc) {
    final data = doc.data();
    return CalendarEventData(
      date: data['date'].toDate(),
      startTime: data['startTime'].toDate(),
      endTime: data['endTime'].toDate(),
      title: data['title'],
      description: data['description'],
    );
  }).toList();

  return [..._events, ...events];
}
