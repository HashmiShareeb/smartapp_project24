// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(Duration(hours: 1));
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay(
    hour: TimeOfDay.now().hour + 1,
    minute: TimeOfDay.now().minute,
  );

  

  bool _isAllDay = false; // Added variable to track all-day status

  final db = FirebaseFirestore.instance;
  void addEvent() async {
    await db
        .collection(
            'project_sm/${FirebaseAuth.instance.currentUser!.uid}/events')
        .add({
          'startDate': _selectedStartDate,
          'endDate': _selectedEndDate,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'startTime': DateTime(
            _selectedStartDate.year,
            _selectedStartDate.month,
            _selectedStartDate.day,
            _selectedStartTime.hour,
            _selectedStartTime.minute,
          ),
          'endTime': DateTime(
            _selectedEndDate.year,
            _selectedEndDate.month,
            _selectedEndDate.day,
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
  }

  //datepicker void
  Future<void> _datePicker(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          // Ensure end date is always after start date
          if (_selectedEndDate.isBefore(_selectedStartDate)) {
            _selectedEndDate = _selectedStartDate.add(Duration(hours: 1));
          }
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  //timepicker void
  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedStartTime : _selectedEndTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
          // Ensure end time is always after start time
          // Check if the end time is on the next day
          if (_selectedEndTime.hour >= 24) {
            _selectedEndTime = TimeOfDay(
              hour: _selectedEndTime.hour % 24,
              minute: _selectedEndTime.minute,
            );
          }
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  Color _selectedColor = Colors.lightBlue;

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

  //?toggle all day event
  //!Switch onChanged callback
  void _toggleAllDay(bool value) {
    setState(() {
      _isAllDay = value;

      //!Update start and end times accordingly
      if (_isAllDay) {
        _selectedStartTime = TimeOfDay(hour: 0, minute: 0);
        _selectedEndTime = TimeOfDay(hour: 23, minute: 59);
      } else {
        _selectedStartTime = TimeOfDay.now();
        _selectedEndTime = TimeOfDay(
          hour: TimeOfDay.now().hour + 1,
          minute: TimeOfDay.now().minute,
        );
      }
    });
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
              //? title textfield
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
                onChanged: (value) {
                  if (value.isEmpty) {
                    _titleController.text = 'My Event';
                  }
                },
              ),
              const SizedBox(height: 16),
              //? Description textfield
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
                  hintText: 'Event description',
                  fillColor: Colors.white,
                  filled: true,
                ),
                maxLines: null,
                validator: (value) {
                  return null; // Remove the validation for description
                },
              ),

              //? toggle all day event
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
                leading: Icon(Icons.calendar_today_rounded),
                title: Text('Start Date'),
                trailing: Text(
                  DateFormat("dd/MM/yyyy").format(_selectedStartDate),
                ),
                onTap: () => _datePicker(context, true),
              ),
              ListTile(
                leading: Icon(Icons.calendar_month_rounded),
                title: Text('End Date'),
                trailing: Text(
                  DateFormat("dd/MM/yyyy").format(_selectedEndDate),
                ),
                onTap: () => _datePicker(context, false),
              ),
              ListTile(
                leading: Icon(Icons.access_time_filled_outlined),
                title: Text('Start Time'),
                trailing: Text(
                  _selectedStartTime.format(context),
                ),
                onTap: () => _pickTime(context, true),
              ),
              ListTile(
                leading: Icon(Icons.access_time_filled),
                title: Text('End Time'),
                trailing: Text(
                  _selectedEndTime.format(context),
                ),
                onTap: () => _pickTime(context, false),
              ),
              ListTile(
                leading: Icon(Icons.color_lens_rounded),
                title: const Text('Color'),
                trailing: CircleAvatar(
                  backgroundColor: _selectedColor,
                  radius: 15,
                ),
                onTap: _pickColor,
              ),
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
                // Add your code here
                CalendarControllerProvider.of(context)
                    .controller
                    .add(CalendarEventData(
                      date: _selectedStartDate,
                      endDate: _selectedEndDate,
                      event: _titleController.text,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      startTime: DateTime(
                        _selectedStartDate.year,
                        _selectedStartDate.month,
                        _selectedStartDate.day,
                        _selectedStartTime.hour,
                        _selectedStartTime.minute,
                      ),
                      endTime: DateTime(
                        _selectedEndDate.year,
                        _selectedEndDate.month,
                        _selectedEndDate.day,
                        _selectedEndTime.hour,
                        _selectedEndTime.minute,
                      ),
                      color: Color(int.parse(
                          _selectedColor.value.toRadixString(16),
                          radix: 16)),
                    ));
                Navigator.pop(context);
                addEvent();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, shape: CircleBorder(), backgroundColor: Colors.orange[600],
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
