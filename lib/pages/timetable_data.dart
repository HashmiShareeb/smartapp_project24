// timetable_page.dart or your page file

// ignore_for_file: invalid_return_type_for_catch_error, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/main.dart';
import 'package:smartapp_project24/pages/events/event_edit.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:smartapp_project24/pages/events/event_form.dart';

class TimeTableData extends StatefulWidget {
  const TimeTableData({super.key});

  @override
  _TimeTableDataState createState() => _TimeTableDataState();
}

class _TimeTableDataState extends State<TimeTableData> {
  late int _selectedIndex;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print('Init state called');
    _selectedIndex = 0;
    fetchEventsFromFirestore();
  }

  Future<void> fetchEventsFromFirestore() async {
    // final events = CalenderControllerProvider.of(context).controller.

    if (FirebaseAuth.instance.currentUser == null) {
      db
          .collection(
              'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
          .get()
          .then(
        (QuerySnapshot snapshot) {
          for (var doc in snapshot.docs) {
            List<CalendarEventData> events = snapshot.docs.map((doc) {
              DateTime date = (doc['startDate'] as Timestamp).toDate();
              DateTime startTime = (doc['startTime'] as Timestamp).toDate();
              DateTime endTime = (doc['endTime'] as Timestamp).toDate();
              String title = doc['title'];
              String description = doc['description'];
              Color color = Color(doc['color']);
              DateTime endDate = (doc['endDate'] as Timestamp).toDate();

              return CalendarEventData(
                date: date,
                startTime: startTime,
                endTime: endTime,
                title: title,
                description: description,
                color: color,
                endDate: endDate,
              );
            }).toList();
            print("added ${doc['title']}");

            setState(() {
              events.addAll(events);
            });
          }
        },
      ).catchError(
        (error) => print('Failed to fetch events: $error'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    EventController c = CalendarControllerProvider.of(context).controller;
    c.addAll(fetchedEvents);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 25.0,
            ),
            onPressed: () async {
              final c = await Navigator.push<CalendarEventData>(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventFormPage(),
                ),
              );

              if (c != null) {
                db
                    .collection(
                        'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
                    .add({
                  'startDate': c.date,
                  'startTime': c.startTime,
                  'endTime': c.endTime,
                  'title': c.title,
                  'description': c.description,
                  'color':
                      c.color.value.toRadixString(16), // Convert color to hex
                  'endDate': c.endDate,
                });
              }
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            onSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<int>>[
                const PopupMenuItem(
                  value: 0,
                  child: Text('Day View'),
                ),
                const PopupMenuItem(
                  value: 1,
                  child: Text('Week View'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Month View'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchEventsFromFirestore(),
        builder: (context, snapshot) {
          print("inside builder: $snapshot");
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    DayView(
                      controller: c,
                      dateStringBuilder: (date, {secondaryDate}) =>
                          DateFormat('EEEE, d MMMM yyyy').format(date),
                      onEventTap: (c, date) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventEditPage(event: c[0]),
                          ),
                        );
                      },
                      eventTileBuilder: (date, events, boundry, start, end) {
                        if (events.isEmpty) {
                          return Container();
                        }

                        final c = events.first;

                        if (c.endTime!.difference(c.startTime!).inHours == 1) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: c.color,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.title,
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
                                  builder: (context) => EventEditPage(event: c),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: c.color,
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
                                        c.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        c.description ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('HH:mm').format(c.startTime!)} - ${DateFormat('HH:mm').format(c.endTime ?? DateTime.now())}',
                                        style: const TextStyle(
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
                      startHour: 0,
                      // To Hide day header
                    ),
                    WeekView(
                      controller: c,
                      headerStringBuilder: (date, {secondaryDate}) =>
                          DateFormat('d MMMM yyyy').format(date),
                      startDay: WeekDays.monday,
                      onEventTap: (c, date) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventEditPage(event: c[0]),
                          ),
                        );
                      },
                      startHour: 0,
                    ),
                    MonthView(
                      controller: c,
                      headerStringBuilder: (date, {secondaryDate}) =>
                          DateFormat(' MMMM yyyy').format(date),
                      dateStringBuilder: (date, {secondaryDate}) =>
                          DateFormat('MMMM yyyy').format(date),
                      minMonth: DateTime(1990),
                      maxMonth: DateTime(2100),
                      initialMonth: DateTime.now(),
                      cellAspectRatio: 1,
                      onPageChange: (date, pageIndex) =>
                          print("$date, $pageIndex"),

                      showBorder: true,
                      // This callback will only work if cellBuilder is null.
                      onEventTap: (c, date) {
                        // Implement callback when user taps on a cell.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => EventEditPage(event: c),
                          ),
                        );
                        print(c);
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
