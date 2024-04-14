import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  final CalendarEventData event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);

    // DateTime _selectedDate = DateTime.now();
    // TimeOfDay _selectedTime = TimeOfDay.now();
    // TimeOfDay _selectedEndTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //custom back arrow ios
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.event.title),
      ),
      body: Padding(
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
                hintText: 'Event description',
                fillColor: Colors.white,
                filled: true,
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Update event details
                    final updatedEvent = widget.event.copyWith(
                      title: _titleController.text,
                      description: _descriptionController.text,
                    );
                    CalendarControllerProvider.of(context)
                        .controller
                        .update(widget.event, updatedEvent);
                    Navigator.of(context).pop();
                  },
                  child: Text('Save Changes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Delete event
                    CalendarControllerProvider.of(context)
                        .controller
                        .remove(widget.event);
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
