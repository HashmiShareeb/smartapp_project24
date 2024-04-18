import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final CalendarEventData event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TimeOfDay _selectedEndTime;
  late Color _selectedColor;
  late Color _appBarColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _selectedDate = widget.event.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.startTime!);
    _selectedEndTime = TimeOfDay.fromDateTime(widget.event.endTime!);
    _selectedColor = widget.event.color;
    _appBarColor = widget.event.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final db = FirebaseFirestore.instance;
  // Future<void> deleteAllEvents() async {
  //   final collectionRef = db.collection(
  //       'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');
  //   final batch = db.batch();

  //   // Get all documents in batches (optional for large collections)
  //   await collectionRef.get().then((querySnapshot) {
  //     querySnapshot.docChanges.forEach((change) {
  //       batch.delete(change.doc.reference);
  //     });
  //   });

  //   await batch.commit().then((_) => print('All events deleted'));
  // }

  Future<void> deleteEventsByTitle(String title) async {
    final collectionRef = db.collection(
        'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');
    final querySnapshot =
        await collectionRef.where('title', isEqualTo: title).get();

    querySnapshot.docChanges.forEach((change) {
      change.doc.reference.delete();
    });

    print('Events with title: $title deleted');
  }

  //edit event
  Future<void> editEvent(
    String title,
    String description,
    DateTime date,
    DateTime startTime,
    DateTime endTime,
    int color,
  ) async {
    final collectionRef = db.collection(
        'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');
    final querySnapshot =
        await collectionRef.where('title', isEqualTo: widget.event.title).get();

    querySnapshot.docChanges.forEach((change) {
      change.doc.reference.update({
        'title': title,
        'description': description,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'color': color,
      });
    });

    print('Event edited');
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(
        () {
          _selectedTime = picked;
          // Ensure end time is at least one hour ahead of start time
          if (_selectedTime.hour + 1 >= 24) {
            _selectedEndTime = TimeOfDay(hour: 0, minute: _selectedTime.minute);
          } else {
            _selectedEndTime = TimeOfDay(
                hour: _selectedTime.hour + 1, minute: _selectedTime.minute);
          }
        },
      );
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _pickColor(BuildContext context) async {
    Color? newColor = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedColor);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (newColor != null) {
      setState(() {
        _selectedColor = newColor;
        _appBarColor = _selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.event.title,
          style: TextStyle(
            color: _appBarColor.computeLuminance() > 0.8
                ? Colors.black.withOpacity(0.8)
                : Colors.white,
          ),
        ),
        backgroundColor: _appBarColor,
        //if color is dark white text if lighter color black text
        foregroundColor: _appBarColor.computeLuminance() > 0.8
            ? Colors.black.withOpacity(0.8)
            : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                autocorrect: true,
                controller: _titleController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.lightBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Event Title',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                autocorrect: true,
                controller: _descriptionController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.lightBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Event Description',
                  fillColor: Colors.white,
                  filled: true,
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date'),
                trailing: Text(
                  DateFormat("dd/MM/yyyy").format(_selectedDate),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Start Time'),
                trailing: Text(
                  _selectedTime.format(context),
                ),
                onTap: () => _pickStartTime(context),
              ),
              ListTile(
                title: Text('End Time'),
                trailing: Text(
                  _selectedEndTime.format(context),
                ),
                onTap: () => _pickEndTime(context),
              ),
              ListTile(
                title: const Text('Color'),
                trailing: CircleAvatar(
                  backgroundColor: _selectedColor,
                  radius: 15,
                ),
                onTap: () => _pickColor(context),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDate != widget.event.date) {
                        // Remove the event from the previous date
                        CalendarControllerProvider.of(context)
                            .controller
                            .remove(widget.event);
                        // Add the event to the new date
                        final updatedEvent = widget.event.copyWith(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          date: _selectedDate,
                          startTime: DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          ),
                          endTime: DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedEndTime.hour,
                            _selectedEndTime.minute,
                          ),
                          color: _selectedColor,
                        );
                        CalendarControllerProvider.of(context)
                            .controller
                            .add(updatedEvent);
                      } else {
                        // If the date remains the same, simply update the event
                        final updatedEvent = widget.event.copyWith(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          startTime: DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          ),
                          endTime: DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedEndTime.hour,
                            _selectedEndTime.minute,
                          ),
                          color: _selectedColor,
                        );
                        CalendarControllerProvider.of(context)
                            .controller
                            .update(widget.event, updatedEvent);
                      }
                      Navigator.of(context).pop();
                      editEvent(
                        _titleController.text,
                        _descriptionController.text,
                        _selectedDate,
                        DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        ),
                        DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedEndTime.hour,
                          _selectedEndTime.minute,
                        ),
                        _selectedColor.value,
                      );
                    },
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your code here
          CalendarControllerProvider.of(context)
              .controller
              .remove(widget.event);
          Navigator.of(context).pop();
          deleteEventsByTitle(widget.event.title);
        },
        child: Icon(Icons.delete),
        shape: const CircleBorder(),
      ),
      //save button
    );
  }
}
