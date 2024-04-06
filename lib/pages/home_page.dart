// ignore_for_file: prefer_const_constructors

import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/course_page.dart';
import 'package:smartapp_project24/pages/profiles_page.dart';
import 'package:smartapp_project24/pages/tasks_page.dart';
import 'package:smartapp_project24/pages/timetable_data.dart';

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
              foregroundColor: Colors.teal[500],
              backgroundColor: Colors.teal[50],
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
                        color: Colors.teal[500],
                      ),
                    )
                  : null,
              actions: [
                //filter button
                IconButton(
                  onPressed: () {
                    //TODO: Add filter functionality
                  },
                  icon: Icon(
                    Icons.filter_alt_sharp,
                    color: Colors.teal[500],
                  ),
                ),
                // Add filter dropdown here
              ],
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'My courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? TimeTableData()
          : _selectedIndex == 1
              ? CoursePage()
              : _selectedIndex == 2
                  ? TasksPage()
                  : ProfilePage(),
    );
  }
}
