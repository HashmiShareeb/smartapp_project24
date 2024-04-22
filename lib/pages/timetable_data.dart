// timetable_page.dart or your page file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';
import 'package:smartapp_project24/pages/events/event_form.dart';
import 'package:smartapp_project24/pages/events/events_provider.dart';
import 'package:calendar_view/calendar_view.dart';

class TimeTableData extends StatefulWidget {
  const TimeTableData({Key? key}) : super(key: key);

  @override
  _TimeTableDataState createState() => _TimeTableDataState();
}

class _TimeTableDataState extends State<TimeTableData> {
  late int _selectedIndex;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  Stream<List<CalendarEventData>> fetchEventsFromFirestore() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]); // Return empty list if no user is logged in
    }

    return db
        .collection('project_sm/${user.uid}/events')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CalendarEventData(
          date: (doc['date'] as Timestamp).toDate(),
          startTime: (doc['startTime'] as Timestamp).toDate(),
          endTime: (doc['endTime'] as Timestamp).toDate(),
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
          color: Color(doc['color'] ?? Colors.lightBlue),
          endDate: (doc['endDate'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        automaticallyImplyLeading: false,
        actions: [
          DropdownButton<int>(
            value: _selectedIndex,
            onChanged: (int? newIndex) {
              setState(() {
                _selectedIndex = newIndex!;
              });
            },
            dropdownColor: Colors.lightBlue[800],
            items: [
              DropdownMenuItem<int>(
                value: 0,
                child: Text(
                  'Day',
                  style: TextStyle(color: Colors.lightBlue[50]),
                ),
              ),
              DropdownMenuItem<int>(
                value: 1,
                child: Text(
                  'Week',
                  style: TextStyle(color: Colors.lightBlue[50]),
                ),
              ),
              DropdownMenuItem<int>(
                value: 2,
                child: Text(
                  'Month',
                  style: TextStyle(color: Colors.lightBlue[50]),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 25.0,
            ),
            onPressed: () async {
              final event = await Navigator.push<CalendarEventData>(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventFormPage(),
                  fullscreenDialog: true,
                ),
              );

              if (event != null) {
                db
                    .collection(
                        'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
                    .add({
                  'date': event.date,
                  'startTime': event.startTime,
                  'endTime': event.endTime,
                  'title': event.title,
                  'description': event.description,
                  'color': event.color.value,
                  'endDate': event.endDate,
                });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<CalendarEventData>>(
        stream: fetchEventsFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    DayView(
                      dateStringBuilder: (date, {secondaryDate}) =>
                          DateFormat('d MMMM yyyy').format(date),
                      onEventTap: (event, date) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailPage(event: event[0]),
                          ),
                        );
                      },
                      eventTileBuilder: (date, events, boundry, start, end) {
                        if (events.isEmpty) {
                          return Container();
                        }

                        final event = events.first;

                        if (event != null &&
                            event.endTime!
                                    .difference(event.startTime!)
                                    .inHours ==
                                1) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: event.color,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailPage(event: event),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: event.color,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Material(
                                color: Colors
                                    .transparent, // Make material transparent
                                child: InkWell(
                                  splashColor:
                                      Colors.lightBlue.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        event.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        event.description ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('HH:mm').format(event.startTime!)} - ${DateFormat('HH:mm').format(event.endTime ?? DateTime.now())}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      startHour: 5,
                      // To Hide day header
                    ),
                    WeekView(
                      headerStringBuilder: (date, {secondaryDate}) =>
                          DateFormat('d MMMM yyyy').format(date),
                      startDay: WeekDays.monday,
                      onEventTap: (event, date) {
                        print(event);
                      },
                      startHour: 5,
                    ),
                    MonthView(
                      dateStringBuilder: (date, {secondaryDate}) =>
                          DateFormat('MMMM yyyy').format(date),
                      minMonth: DateTime(1990),
                      maxMonth: DateTime(2100),
                      initialMonth: DateTime.now(),
                      cellAspectRatio: 1,
                      onPageChange: (date, pageIndex) =>
                          print("$date, $pageIndex"),
                      headerBuilder: (date) {
                        return Container(
                          color: Colors.lightBlue[50],
                          height: 50,
                          child: Center(
                            child: Text(
                              DateFormat('MMMM yyyy').format(date),
                              style: TextStyle(
                                color: Colors.lightBlue[800],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                      showBorder: true,
                      // This callback will only work if cellBuilder is null.
                      onEventTap: (event, date) {
                        // Implement callback when user taps on a cell.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailPage(event: event),
                          ),
                        );
                        print(event);
                      },

                      startDay: WeekDays.monday,
                      onDateLongPress: (date) => print(date),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
