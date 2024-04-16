import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';
import 'package:smartapp_project24/pages/events/event_form.dart';

class TimeTableData extends StatefulWidget {
  const TimeTableData({Key? key}) : super(key: key);

  @override
  _TimeTableDataState createState() => _TimeTableDataState();
}

class _TimeTableDataState extends State<TimeTableData> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
    _selectedIndex = 0;
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
          CircleAvatar(
            backgroundColor:
                Colors.lightBlue.withOpacity(0.5), // Set background color
            foregroundColor: Colors.lightBlue[50],
            child: IconButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
              ),
              onPressed: () async {
                final event = await Navigator.push<CalendarEventData>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EventFormPage(),
                    fullscreenDialog: true,
                  ),
                );

                // If an event was returned, add it to the EventController
                if (event != null) {
                  CalendarControllerProvider.of(context).controller.add(event);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
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
                  eventTileBuilder: (date, events, boundry, start, end) {
                    // Return a GestureDetector to enable tapping on the event tile
                    if (events.length == 1 &&
                        events[0]
                                .endTime!
                                .difference(events[0].startTime!)
                                .inHours ==
                            1) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: events[0].color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              events[0].title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        // Navigate to event detail page when tile is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailPage(event: events[0]),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: events[0].color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Material(
                          color:
                              Colors.transparent, // Make material transparent
                          child: InkWell(
                            splashColor: Colors.lightBlue
                                .withOpacity(0.5), // Set splash color
                            borderRadius: BorderRadius.circular(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  events[0].title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  events[0].description ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${DateFormat('HH:mm').format(events[0].startTime!)} - ${DateFormat('HH:mm').format(events[0].endTime ?? DateTime.now())}',
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
                  startDay:
                      WeekDays.monday, // To change the first day of the week.
                  // This callback will only work if cellBuilder is null.
                  onEventTap: (event, date) => print(event),
                  onDateLongPress: (date) => print(date),
                ),
              ],
            ),
          ),
        ],
      ),
      //plus button to add new timetable item eventcontroller
    );
  }
}
