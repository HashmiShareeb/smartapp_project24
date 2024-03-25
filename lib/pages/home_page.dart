// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/course_page.dart';
import 'package:smartapp_project24/pages/profiles_page.dart';
import 'package:smartapp_project24/pages/tasks_page.dart';

class TimetableItem {
  final String courseName;
  final String time;

  TimetableItem({
    required this.courseName,
    required this.time,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
    TimetableItem(courseName: 'Database', time: '6:45 PM - 8:15 PM'),
    TimetableItem(courseName: 'Cyber Security', time: '8:30 PM - 10:00 PM'),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    int countClasses = timetableItems.length;

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
          ? SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: DateFormat('EEEE').format(
                            DateTime.now(),
                          ),
                          style: TextStyle(
                            color: Colors.teal[800],
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '\n${DateFormat('d MMMM').format(
                                DateTime.now(),
                              )}',
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
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      'Today\'s Classes: $countClasses',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Timetable',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: countClasses,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                            timetableItems[index].courseName),
                                        subtitle:
                                            Text(timetableItems[index].time),
                                        trailing: Icon(Icons.more_vert),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Upcoming Tasks',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: ListTile(
                                        title: Text('Task ${index + 1}'),
                                        subtitle: Text(
                                          DateFormat.yMMMd()
                                              .format(DateTime.now()),
                                        ),
                                        trailing: Icon(Icons.more_vert),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _selectedIndex == 1
              ? CoursePage()
              : _selectedIndex == 2
                  ? TasksPage()
                  : ProfilePage(),
    );
  }
}
