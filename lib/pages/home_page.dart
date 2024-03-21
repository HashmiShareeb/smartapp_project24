// ignore_for_file: avoid_unnecessary_containers
//ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimetableItem {
  final String courseName;
  final String time;

  TimetableItem({
    required this.courseName,
    required this.time,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  // Dummy list of timetable items
  List<TimetableItem> timetableItems = [
    TimetableItem(
        courseName: 'Frontend Development', time: '8:00 AM - 9:30 AM'),
    TimetableItem(
        courseName: 'Backend devolopment', time: '9:45 AM - 11:15 AM'),
    TimetableItem(courseName: 'User Experience', time: '11:30 AM - 1:00 PM'),
    TimetableItem(courseName: 'AI', time: '1:30 PM - 3:00 PM'),
    TimetableItem(courseName: 'Scripting', time: '3:15 PM - 4:45 PM'),
    TimetableItem(courseName: 'Networking', time: '5:00 PM - 6:30 PM'),
    TimetableItem(courseName: 'Database', time: '6:45 PM - 8:15 PM'),
    TimetableItem(courseName: 'Cyber Security', time: '8:30 PM - 10:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    int countClasses = timetableItems.length;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        foregroundColor: Colors.teal[800],
        backgroundColor: Colors.tealAccent[100],
        title: Text(
          'Welcome ${user?.displayName ?? 'Guest'}!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: user?.displayName == null ? true : false,
        leading: user?.displayName == null
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.teal[800],
                ),
              )
            : null,
        actions: [
          if (user?.displayName != null)
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                print("logged out ${user?.email}");
              },
              icon: const Icon(Icons.logout),
              color: Colors.teal[800],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          //color teal

          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              color: Colors.tealAccent[100],
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 20.0,
                ),
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    text: DateFormat('EEEE').format(
                      DateTime.now(),
                    ),
                    style: TextStyle(
                      color: Colors.teal[800],
                      fontSize: 20,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\n' +
                            DateFormat('d MMM').format(
                              DateTime.now(),
                            ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: timetableItems.length,
                itemBuilder: (context, index) {
                  final item = timetableItems[index];
                  return ListTile(
                    title: Text(
                      item.courseName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      item.time,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    // You can add more styling here
                    // onTap: () {
                    //   // Handle tap event
                    // },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.search),
          //   label: 'Search',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.teal,
        onTap: (int index) {
          // Handle navigation
        },
      ),
    );
  }
}

