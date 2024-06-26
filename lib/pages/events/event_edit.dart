// ignore_for_file: prefer_const_constructors

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

class EventEditPage extends StatefulWidget {
  final CalendarEventData event;

  const EventEditPage({super.key, required this.event});

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late DateTime _selectedEndDate;
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
    _selectedEndDate = widget.event.date;
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

  bool _isAllDay = false; // Added variable to track all-day status
  final db = FirebaseFirestore.instance;

  Future<void> deleteEventsByTitle(String title) async {
    final collectionRef = db.collection(
        'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');
    final querySnapshot =
        await collectionRef.where('title', isEqualTo: title).get();

    for (var change in querySnapshot.docChanges) {
      change.doc.reference.delete();
    }

    print('Events with title: $title deleted');
  }

  Future<void> editEvent(
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,
    DateTime startTime,
    DateTime endTime,
    int color,
  ) async {
    final collectionRef = db.collection(
        'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events');
    final querySnapshot =
        await collectionRef.where('title', isEqualTo: widget.event.title).get();

    for (var change in querySnapshot.docChanges) {
      change.doc.reference.update({
        'title': title,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'startTime': startTime,
        'endTime': endTime,
        'color': color,
      });
    }

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

  //?all day switch
  void _toggleAllDay(bool value) {
    setState(() {
      if (_isAllDay != value) {
        // Only update start and end times if the all-day status changes
        _isAllDay = value;
        if (_isAllDay) {
          _selectedTime = TimeOfDay(hour: 0, minute: 0);
          _selectedEndTime = TimeOfDay(hour: 23, minute: 59);
        } else {
          _selectedTime = TimeOfDay.fromDateTime(widget.event.startTime!);
          _selectedEndTime = TimeOfDay.fromDateTime(widget.event.endTime!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: _appBarColor.computeLuminance() > 0.5
                ? Colors.black54
                : Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          //icon closed

          IconButton(
            icon: Icon(
              Icons.check_rounded,
              color: _appBarColor.computeLuminance() > 0.5
                  ? Colors.black54
                  : Colors.white,
            ),
            onPressed: () {
              if (_selectedDate != widget.event.date ||
                  _selectedEndDate != widget.event.date) {
                // Remove the event from the previous date
                CalendarControllerProvider.of(context)
                    .controller
                    .remove(widget.event);
                // Add the event to the new date range
                final updatedEvent = widget.event.copyWith(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  date: _selectedDate,
                  endDate: _selectedEndDate,
                  startTime: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
                  endTime: DateTime(
                    _selectedEndDate.year,
                    _selectedEndDate.month,
                    _selectedEndDate.day,
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
                    _selectedEndDate.year,
                    _selectedEndDate.month,
                    _selectedEndDate.day,
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
                _selectedEndDate,
                DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                ),
                DateTime(
                  _selectedEndDate.year,
                  _selectedEndDate.month,
                  _selectedEndDate.day,
                  _selectedEndTime.hour,
                  _selectedEndTime.minute,
                ),
                _selectedColor.value,
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        title: Text(
          "Edit: ${widget.event.title}",
          style: TextStyle(
            color: _appBarColor.computeLuminance() > 0.5
                ? Colors.black54
                : Colors.white,
          ),
        ),
        backgroundColor: _appBarColor,
        foregroundColor: _appBarColor.computeLuminance() > 0.5
            ? Colors.black54
            : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
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
              TextFormField(
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
                //if event is not from read only, remove the validation for description
                maxLines: null,
                validator: (value) {
                  return null; // Remove the validation for description
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.event_available_sharp),
                title: Text('All Day'),
                trailing: Switch(
                  value: _isAllDay,
                  onChanged: (value) => _toggleAllDay(value),
                  activeColor: _selectedColor,
                  activeTrackColor: _selectedColor.withOpacity(0.5),
                ),
              ),
              ListTile(
                title: const Text('Start Date'),
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
                title: const Text('End Date'),
                trailing: Text(
                  DateFormat("dd/MM/yyyy").format(_selectedEndDate),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedEndDate,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _selectedEndDate) {
                    setState(() {
                      _selectedEndDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('Start Time'),
                trailing: Text(
                  _selectedTime.format(context),
                ),
                onTap: () => _pickStartTime(context),
              ),
              ListTile(
                title: const Text('End Time'),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        //delete button
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                CalendarControllerProvider.of(context)
                    .controller
                    .remove(widget.event);
                Navigator.of(context).pop();
                deleteEventsByTitle(widget.event.title);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                backgroundColor: Colors.orange[500],
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
