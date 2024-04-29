// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartapp_project24/firebase_options.dart';
import 'package:smartapp_project24/pages/auth/login_page.dart';
import 'package:google_fonts/google_fonts.dart';

DateTime get _now => DateTime.now();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  fetchEventsFromFirestore();

  runApp(MainApp(_events));
}

class MainApp extends StatelessWidget {
  const MainApp(List<CalendarEventData<Object?>> events, {super.key});

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
          dialogTheme: DialogTheme(
            backgroundColor: Colors.grey[100],
            titleTextStyle: TextStyle(
              color: Colors.lightBlue[900],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          fontFamily: GoogleFonts.dmSans().fontFamily,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.orange, // 30% Accent - Button background
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
  // CalendarEventData(
  //   date: fetchedEvents[0].date,
  //   title: fetchedEvents[0].title,
  //   description: fetchedEvents[0].description,
  //   startTime: fetchedEvents[0].startTime,
  //   endTime: fetchedEvents[0].endTime,
  //   endDate: fetchedEvents[0].endDate,
  //   color: fetchedEvents[0].color,
  // ),
];

void fetchEventsFromFirestore() async {
  // Fetch events from Firestore
  if (FirebaseAuth.instance.currentUser == null) {
    return null;
  }
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
      .get();

  // Convert Firestore documents to CalendarEventData objects
  List<CalendarEventData> events = querySnapshot.docs.map((doc) {
    DateTime date = (doc['startDate'] as Timestamp).toDate();
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

  //fetchedEvents = events;
  fetchedEvents.addAll(events);
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
    date: DateTime(2024, 4, 23),
    startTime: DateTime(_now.year, _now.month, _now.day, 13, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 17, 45),
    title: "SmartApp Development",
    description: "Consult Flutter Project",
    color: Colors.lightBlue,
  ),
  CalendarEventData(
    date: DateTime(2024, 5, 24),
    startTime: DateTime(_now.year, _now.month, _now.day, 13, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 17, 45),
    title: "Backend Development",
    description: ".NET and dapr",
    color: Colors.lightBlue,
  ),
  CalendarEventData(
    date: DateTime(2024, 5, 25),
    startTime: DateTime(_now.year, _now.month, _now.day, 13, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 17, 45),
    title: "User Experience Design",
    description: "Adobe After Effects",
    color: Color.fromARGB(255, 15, 174, 23),
  ),
  CalendarEventData(
    date: DateTime(2024, 5, 26),
    startTime: DateTime(_now.year, _now.month, _now.day, 13, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 17, 45),
    title: "User Experience Design",
    description: "Adobe After Effects",
    color: Colors.lightBlue,
  ),
  CalendarEventData(
    date: DateTime(2024, 5, 29),
    startTime: DateTime(_now.year, _now.month, _now.day, 13, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 17, 45),
    title: "SmartApp Development",
    description: "Presentation Flutter Project",
    color: const Color.fromARGB(255, 154, 20, 10),
  ),
  CalendarEventData(
    date: DateTime(2024, 5, 2),
    startTime: DateTime(_now.year, _now.month, _now.day, 8, 45),
    endTime: DateTime(_now.year, _now.month, _now.day, 14, 45),
    title: "Backend Development",
    description: "Exams .NET and dapr",
    color: const Color.fromARGB(255, 154, 20, 10),
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 1)),
    startTime: DateTime(_now.year, _now.month, _now.day, 18),
    endTime: DateTime(_now.year, _now.month, _now.day, 19),
    title: "Frontend Development",
    description: "Portfolio.",
    color: const Color.fromARGB(255, 154, 20, 10),
  ),
  CalendarEventData(
    date: _now,
    startTime: DateTime(_now.year, _now.month, _now.day, 14),
    endTime: DateTime(_now.year, _now.month, _now.day, 17),
    title: "SmartApp Development",
    description: "Project presentation.",
    color: const Color.fromARGB(255, 154, 20, 10),
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 3)),
    startTime: DateTime(_now.add(Duration(days: 4)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 10),
    endTime: DateTime(_now.add(Duration(days: 4)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 14),
    title: "Backend Development",
    description: "Last day of project submission.",
    color: const Color.fromARGB(255, 154, 20, 10),
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        14),
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        16),
    title: "User Experience Design",
    description: "adobe after effects.",
    color: const Color.fromARGB(255, 154, 20, 10),
  ),
];
