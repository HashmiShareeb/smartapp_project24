// ignore_for_file: prefer_const_constructors

import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/course_page.dart';
import 'package:smartapp_project24/pages/profiles_page.dart';
import 'package:smartapp_project24/pages/tasks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[200],
      appBar: _selectedIndex == 0
          ? AppBar(
              foregroundColor: Colors.teal[800],
              backgroundColor: Colors.white,
              title: Text(
                'Hello, ${user?.displayName ?? 'Guest'}!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              automaticallyImplyLeading:
                  user?.displayName == null ? true : false,
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
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'My courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? DayView(
              dateStringBuilder: (date, {secondaryDate}) =>
                  DateFormat('d MMMM yyyy').format(date),
            )
          : _selectedIndex == 1
              ? CoursePage()
              : _selectedIndex == 2
                  ? TasksPage()
                  : ProfilePage(),
    );
  }
}
