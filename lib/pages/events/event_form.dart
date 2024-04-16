// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:smartapp_project24/models/event.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({Key? key}) : super(key: key);

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();

  // final event = Event(
  //   id: FirebaseAuth.instance.currentUser!.uid,
  //   date: DateTime.now(),
  //   title: '',
  //   event: '',
  //   description: '',
  //   startTime: TimeOfDay.now(),
  //   endTime: TimeOfDay.now(),
  // );

  final db = FirebaseFirestore.instance;
  void addEvent() async {
    await db
        .collection(
            'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
        .add({
          'date': _selectedDate,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'startTime': DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ),
          'endTime': DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedEndTime.hour,
            _selectedEndTime.minute,
          ),
          'color': Color(
                  int.parse(_selectedColor.value.toRadixString(16), radix: 16))
              .value,
        })
        .then(
          (value) => print('Event added'),
        )
        .catchError(
          (error) => print('Failed to add event: $error'),
        );

    //if event added show snackbar
  }

  //datepicker void
  Future<void> _datePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  //timepicker void
  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != TimeOfDay.now()) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  //timepicker void
  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != TimeOfDay.now()) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Color _selectedColor = Colors.lightBlue; // Default event color

  // Color picker void
  Future<void> _pickColor() async {
    showDialog(
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
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Event'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                    hintText: 'Event description',
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
                  onTap: () => _datePicker(context),
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
                  onTap: _pickColor,
                ),
                ElevatedButton(
                  onPressed: () {
                    final event = CalendarEventData(
                      date: _selectedDate,
                      event: _titleController.text,
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
                      color: Color(int.parse(
                          _selectedColor.value.toRadixString(16),
                          radix: 16)),
                    );

                    CalendarControllerProvider.of(context)
                        .controller
                        .add(event);

                    Navigator.pop(
                        context); // Navigate back to the previous page

                    addEvent();
                  },
                  child: Text('Add Event'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your code here
            CalendarControllerProvider.of(context)
                .controller
                .add(CalendarEventData(
                  date: _selectedDate,
                  event: _titleController.text,
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
                  color: Color(int.parse(_selectedColor.value.toRadixString(16),
                      radix: 16)),
                ));
            Navigator.pop(context);
            addEvent();
          },
          child: const Icon(Icons.add),
        ));
  }
}
