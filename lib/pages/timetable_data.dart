import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';
import 'package:smartapp_project24/pages/events/event_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeTableData extends StatefulWidget {
  const TimeTableData({Key? key}) : super(key: key);

  @override
  _TimeTableDataState createState() => _TimeTableDataState();
}

class _TimeTableDataState extends State<TimeTableData> {
  late int _selectedIndex;
  List<CalendarEventData> _events = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _fetchEventsFromFirestore();
  }

  Future<void> _fetchEventsFromFirestore() async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance
          .collection(
              'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');

      QuerySnapshot eventsSnapshot = await eventsCollection.get();

      List<CalendarEventData> firestoreEvents = eventsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime date = data['date'].toDate();
        DateTime startTime = data['startTime'].toDate();
        DateTime endTime = data['endTime'].toDate();
        String title = data['title'];
        String description = data['description'];
        String color = data['color'];

        return CalendarEventData(
          date: date,
          startTime: startTime,
          endTime: endTime,
          title: title,
          description: description,
          color: Color(
            int.parse(color),
          ),
        );
      }).toList();

      setState(() {
        _events.addAll(firestoreEvents);
      });
    } catch (error) {
      print('Error fetching events from Firestore: $error');
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
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
            items: [
              DropdownMenuItem<int>(
                value: 0,
                child: Text('Day'),
              ),
              DropdownMenuItem<int>(
                value: 1,
                child: Text('Week'),
              ),
              DropdownMenuItem<int>(
                value: 2,
                child: Text('Month'),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
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
                CalendarControllerProvider.of(context).controller.add(event);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
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
                            EventDetailPage(event: event as CalendarEventData),
                      ),
                    );
                  },
                  eventTileBuilder: (date, events, boundry, start, end) {
                    if (events.isEmpty) {
                      return Container();
                    }

                    final event = events.first;

                    if (event != null &&
                        event.endTime!.difference(event.startTime!).inHours ==
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
                            color:
                                Colors.transparent, // Make material transparent
                            child: InkWell(
                              splashColor: Colors.lightBlue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                  // To Hide day header
                ),
                WeekView(
                  headerStringBuilder: (date, {secondaryDate}) =>
                      DateFormat('d MMMM yyyy').format(date),
                  startDay: WeekDays.monday,
                ),
                MonthView(
                  dateStringBuilder: (date, {secondaryDate}) =>
                      DateFormat('MMMM yyyy').format(date),
                  minMonth: DateTime(1990),
                  maxMonth: DateTime(2100),
                  initialMonth: DateTime.now(),
                  cellAspectRatio: 1,
                  onPageChange: (date, pageIndex) => print("$date, $pageIndex"),
                  onCellTap: (events, date) {
                    // Implement callback when user taps on a cell.
                    print(events);
                  },
                  startDay: WeekDays.monday,
                  // This callback will only work if cellBuilder is null.
                  onEventTap: (event, date) => print(event),
                  onDateLongPress: (date) => print(date),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
