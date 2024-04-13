import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/timetable_data.dart';

class TimetableItem {
  final String courseName;
  final String time;

  TimetableItem({
    required this.courseName,
    required this.time,
  });
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  // Dummy list of timetable items
  List<TimetableItem> timetableItems = [
    TimetableItem(
      courseName: 'Frontend Development',
      time: '8:00 AM - 9:30 AM',
    ),
    TimetableItem(
      courseName: 'Backend Development',
      time: '9:45 AM - 11:15 AM',
    ),
    TimetableItem(
      courseName: 'User Experience',
      time: '11:30 AM - 1:00 PM',
    ),
    TimetableItem(
      courseName: 'Database',
      time: '6:45 PM - 8:15 PM',
    ),
    TimetableItem(
      courseName: 'Cyber Security',
      time: '8:30 PM - 10:00 PM',
    ),
  ];

  // Count of classes
  int get countClasses => timetableItems.length;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Container(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.teal[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: DateFormat('EEEE').format(
                          DateTime.now(),
                        ),
                        style: TextStyle(
                          color: Colors.teal[500],
                          fontSize: 16,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n${DateFormat('d MMMM').format(
                              DateTime.now(),
                            )}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.teal[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // CircleAvatar(
                    //   radius: 25,
                    //   backgroundColor: Colors.teal[800],
                    //   child: Icon(
                    //     Icons.calendar_today,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
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
                  fontWeight: FontWeight.w600,
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
                      size: 20,
                    ),
                    // Tile background color
                    // tileColor: Colors.grey[200],
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
    );
  }
}
