// ignore_for_file: avoid_unnecessary_containers
//ignore_for_file: prefer_const_constructors

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
    TimetableItem(courseName: 'Database', time: '6:45 PM - 8:15 PM'),
    TimetableItem(courseName: 'Cyber Security', time: '8:30 PM - 10:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    int countClasses = timetableItems.length;
    int _selectedIndex = 0;

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    List<Widget> _widgetOptions = <Widget>[
      HomePage(),
      CoursePage(),
      TasksPage(),
      ProfilePage(),
    ];

    return Scaffold(
      // backgroundColor: Colors.grey[200],
      appBar: AppBar(
        foregroundColor: Colors.teal[800],
        backgroundColor: Colors.white,
        title: Text(
          'Hello, ${user?.displayName ?? 'Guest'}!',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              // color: Colors.white,
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
              child: ListView.separated(
                itemCount: timetableItems.length,
                separatorBuilder: (context, index) => SizedBox(height: 10),
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
                    // You can add more styling here
                    style: ListTileStyle.list,
                    // Subtitle styling
                    subtitle: Text(
                      item.time,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),

                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.teal[800],
                    ),
                    // Tile background color
                    // tileColor: Colors.tealAccent[100],
                    // Content padding
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    onTap: () {
                      // Handle tap event
                      print('Tapped on ${item.courseName}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CoursePage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TasksPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'My courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_4_outlined),
            label: 'Profile',
          ),
        ],
      ),

      //   backgroundColor: Colors.teal,
      //   onPressed: () {
      //     // Add new class
      //   },
      //   child: const Icon(Icons.add),
      //   tooltip: 'Add Activity',
      // ),
    );
  }
}
