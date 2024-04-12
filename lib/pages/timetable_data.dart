import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartapp_project24/pages/event_form.dart';

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
        title: const Text('Calendar'),
        //custom back arrow button
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        //customizing the appbar

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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                DayView(
                  dateStringBuilder: (date, {secondaryDate}) =>
                      DateFormat('d MMMM yyyy').format(date),
                  eventTileBuilder: (date, events, boundry, start, end) {
                    // Return a Container with the calculated height and event content
                    if (events[0]
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
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors
                            .teal, // Customize the background color as needed
                        borderRadius: BorderRadius.circular(5.0),
                      ),
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
                    );
                  },
                  dayTitleBuilder: DayHeader.hidden, // To Hide day header
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

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the EventFormPage and wait for the result
          final event = await Navigator.push<CalendarEventData>(
            context,
            MaterialPageRoute(
              builder: (context) => const EventFormPage(),
            ),
          );

          // If an event was returned, add it to the EventController
          if (event != null) {
            CalendarControllerProvider.of(context).controller.add(event);
          }

          // final event = CalendarEventData(
          //   date: DateTime.now(),
          //   event: "Event 1",
          //   title: 'event 1',
          //   description: 'event 1 description',
          //   startTime: DateTime(2024, 3, 30, 8),
          //   endTime: DateTime(2024, 3, 30, 10),
          // );
          // CalendarControllerProvider.of(context).controller.add(event);
        },
        child: Icon(Icons.add, color: Colors.teal[800]),
        shape: CircleBorder(),
        backgroundColor: Colors.teal[50],
      ),
    );
  }
}

// class TimetableItem extends StatelessWidget {
//   final String courseName;
//   final String time;

//   const TimetableItem({
//     Key? key,
//     required this.courseName,
//     required this.time,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//       child: ListTile(
//         title: Text(courseName),
//         subtitle: Text(time),
//       ),
//     );
//   }
// }
