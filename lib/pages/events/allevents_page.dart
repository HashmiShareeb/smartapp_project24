// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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
      if (user != null) {
        final snapshot = await db
            .collection('project_sm/${user.uid}/events')
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
          fetchedEvents.toList(),
          (CalendarEventData event) => event.date,
        );

        setState(() {
          events = groupedEvents.values.toList();
        });
      }
    } catch (error) {
      print('Error fetching events: $error');
      // Error handling
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

  Future<void> deleteEventsByTitle(String title) async {
    final collectionRef = db.collection(
        'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');
    final querySnapshot =
        await collectionRef.where('title', isEqualTo: title).get();

    for (var change in querySnapshot.docChanges) {
      change.doc.reference.delete();
    }

    print('Events with title: $title deleted');

    await _fetchEvents();
  }

  Widget _buildEventOptionsSheet(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.20, // Adjust height as needed
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Event Options',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Implement logic to delete event from Firestore
                    await deleteEventsByTitle(_selectedEvent!.title);

                    // Update UI to reflect the deleted event (optional)
                    final remainingEvents = events.where((eventList) =>
                        !eventList.any(
                            (event) => event.title == _selectedEvent!.title));
                    setState(() {
                      events = remainingEvents.toList();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event deleted successfully.'),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (error) {
                    // Handle potential errors during event deletion
                    print('Error deleting event: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('An error occurred while deleting the event.'),
                      ),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
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
        title: const Text('All Events'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48.0,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'No events yet!',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _eventController,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: events[index]
                            .map(
                              (event) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 12.0,
                                ),
                                child: ListTile(
                                  title: Text(
                                    event.title,
                                    style: TextStyle(
                                      color:
                                          event.color.computeLuminance() > 0.5
                                              ? Colors.black54
                                              : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  subtitle: Text(
                                    event.description!,
                                    style: TextStyle(
                                      color:
                                          event.color.computeLuminance() > 0.5
                                              ? Colors.black54
                                              : Colors.white70,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: event.color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        event.title.isNotEmpty
                                            ? event.title[0].toUpperCase()
                                            : 'E',
                                        style: TextStyle(
                                          color:
                                              event.color.computeLuminance() >
                                                      0.5
                                                  ? Colors.black45
                                                  : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      color:
                                          event.color.computeLuminance() > 0.5
                                              ? Colors.black54
                                              : Colors.white,
                                    ),
                                    onPressed: () => _showEventOptions(event),
                                  ),
                                  tileColor: event.color.withOpacity(0.6),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
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
