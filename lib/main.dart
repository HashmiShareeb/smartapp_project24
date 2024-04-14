// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
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
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()..addAll(_events),
      child: MaterialApp(
        themeAnimationCurve: Curves.easeInOutCubic,
        //navigation theme
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.lightBlue[50],
            titleTextStyle: TextStyle(
              color: Colors.lightBlue[300],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(
              color: Colors.lightBlue[500],
              size: 20,
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor:
                Colors.amber[500], // 30% Accent - Button background
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
                Colors.amber[500], // 30% Accent - Button background,
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

List<CalendarEventData> _events = [
  CalendarEventData(
    date: _now,
    startTime: DateTime(_now.year, _now.month, _now.day, 8, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 12),
    title: "Frontend Development",
    description: "Theorie Next.js and tailwindcss",
  ),
];
