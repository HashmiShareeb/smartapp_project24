import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:smartapp_project24/pages/events/event_detail.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final db = FirebaseFirestore.instance;
  final _eventController = ScrollController(); // For bottom sheet animation

  List<List<CalendarEventData>> events = []; // Initialize with empty list
  CalendarEventData? _selectedEvent; // Track selected event for bottom sheet

  @override
  void initState() {
    super.initState();
    _fetchEvents(); // Fetch events on initialization
  }

  Future<void> _fetchEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final snapshot = await db
          .collection('project_sm/${user!.uid}/events')
          .orderBy('startDate')
          .get();
      final fetchedEvents = snapshot.docs.map(
        (doc) => CalendarEventData(
          title: doc['title'],
          description: doc['description'],
          date: doc['startDate'].toDate(),
          endDate: doc['endDate'].toDate(),
          color: Color(doc['color']),
          startTime: doc['startTime'].toDate(),
          endTime: doc['endTime'].toDate(),
        ),
      );

      final groupedEvents = groupBy(
        fetchedEvents.toList(), // Ensure events is converted to a list
        (CalendarEventData event) => event.date,
      );

      setState(() {
        events = groupedEvents.values.toList();
      });
    } catch (error) {
      // Handle potential errors during event fetching (e.g., network issues)
      print('Error fetching events: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while fetching events.'),
        ),
      );
    }
  }

  void _showEventOptions(CalendarEventData event) {
    _selectedEvent = event;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow content to scroll if needed
      builder: (context) => _buildEventOptionsSheet(context),
    );
  }

  Widget _buildEventOptionsSheet(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.25, // Adjust height as needed
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Event Options',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement logic to navigate to event edit page
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventDetailPage(event: _selectedEvent!),
                    ),
                  );
                },
                child: Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await deleteEvent(_selectedEvent!.title);
                    Navigator.pop(context);
                  } catch (error) {
                    // Handle potential errors during event deletion
                    print('Error deleting event: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('An error occurred while deleting the event.'),
                      ),
                    );
                  }
                },
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> deleteEvent(String title) async {
    // Implement logic to delete event from Firestore
    final user = FirebaseAuth.instance.currentUser;
    await db.collection('project_sm/${user!.uid}/events').doc(title).delete();

    // Update UI to reflect the deleted event (optional)
    final remainingEvents = events
        .where((eventList) => !eventList.any((event) => event.title == title));
    setState(() {
      events = remainingEvents.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Events'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _eventController,
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Column(
                  children: events[index]
                      .map(
                        (event) => ListTile(
                          title: Text(
                            event.title,
                            style: TextStyle(
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Text(
                            event.description!,
                            style: TextStyle(
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white70,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: event.color,
                            child: Text(
                              event.title[0].toUpperCase(),
                              style: TextStyle(
                                color: event.color.computeLuminance() > 0.5
                                    ? Colors.black54
                                    : Colors.white,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: event.color.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white,
                            ),
                            onPressed: () => _showEventOptions(event),
                          ),
                          tileColor: event.color.withOpacity(0.8),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}