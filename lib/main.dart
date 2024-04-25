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

  runApp(MainApp(_events));
}

class MainApp extends StatelessWidget {
  MainApp(List<CalendarEventData<Object?>> events);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()..addAll([..._events, ...fetchedEvents]),
      child: MaterialApp(
        title: 'Time Table App',
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
            backgroundColor: Colors.lightBlue[900],
            titleTextStyle: TextStyle(
              color: Colors.lightBlue[50],
              fontSize: 20,
              fontWeight: FontWeight.w600,
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
        ),
        themeMode: ThemeMode.system,
        scrollBehavior: ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        home: const LoginPage(),
      ),
    );
  }
}

//list of events from firestore
List<CalendarEventData> fetchedEvents = [
  CalendarEventData(
    date: DateTime(2024, 4, 22),
    title: "Frontend Development",
    description: "Consult Portfolio",
    startTime: DateTime(_now.year, _now.month, _now.day, 10, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 12, 45),
    color: Color.fromARGB(255, 15, 174, 23),
  ),
];

void fetchEventsFromFirestore() async {
  // Fetch events from Firestore
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
      .get();

  // Convert Firestore documents to CalendarEventData objects
  List<CalendarEventData> events = querySnapshot.docs.map((doc) {
    DateTime date = (doc['date'] as Timestamp).toDate();
    DateTime startTime = (doc['startTime'] as Timestamp).toDate();
    DateTime endTime = (doc['endTime'] as Timestamp).toDate();
    String title = doc['title'];
    String description = doc['description'];
    Color color = Color(doc['color']);

    return CalendarEventData(
      date: date,
      startTime: startTime,
      endTime: endTime,
      title: title,
      description: description,
      color: color,
    );
  }).toList();

  fetchedEvents = events;
}

List<CalendarEventData> _events = [
  CalendarEventData(
    date: DateTime(2024, 4, 22),
    title: "Frontend Development",
    description: "Consult Portfolio",
    startTime: DateTime(_now.year, _now.month, _now.day, 10, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 12, 45),
    color: Color.fromARGB(255, 15, 174, 23),
  ),
  CalendarEventData(
    date: DateTime(2024, 4, 22),
    startTime: DateTime(_now.year, _now.month, _now.day, 13, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 15, 45),
    title: "Backend Development",
    description: "Theorie Dapr",
    color: Color.fromARGB(255, 15, 174, 23),
  ),
  CalendarEventData(
    date: DateTime(2024, 4, 24),
    startTime: DateTime(_now.year, _now.month, _now.day, 8, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 12, 30),
    title: "Frontend Development",
    description: "Consult Portfolio",
    color: Colors.lightBlue,
  ),
  CalendarEventData(
    date: DateTime(2024, 4, 24),
    startTime: DateTime(_now.year, _now.month, _now.day, 13, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 17, 45),
    title: "SmartApp Development",
    description: "Consult Flutter Project",
    color: Colors.lightBlue,
  ),
];
