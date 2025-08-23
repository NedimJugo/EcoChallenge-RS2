import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/event.dart';
import 'package:ecochallenge_desktop/providers/event_provider.dart';

class EventFormDialog extends StatefulWidget {
  final EventResponse? event;
  final VoidCallback onSaved;

  const EventFormDialog({
    Key? key,
    this.event,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final EventProvider _eventProvider = EventProvider();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _creatorUserIdController;
  late TextEditingController _locationIdController;
  late TextEditingController _eventTypeIdController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _durationMinutesController;
  late TextEditingController _equipmentListController;
  late TextEditingController _meetingPointController;
  late TextEditingController _statusIdController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _equipmentProvided = false;
  bool _adminApproved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _creatorUserIdController = TextEditingController(text: widget.event?.creatorUserId.toString() ?? '');
    _locationIdController = TextEditingController(text: widget.event?.locationId.toString() ?? '');
    _eventTypeIdController = TextEditingController(text: widget.event?.eventTypeId.toString() ?? '');
    _maxParticipantsController = TextEditingController(text: widget.event?.maxParticipants.toString() ?? '10');
    _durationMinutesController = TextEditingController(text: widget.event?.durationMinutes.toString() ?? '120');
    _equipmentListController = TextEditingController(text: widget.event?.equipmentList ?? '');
    _meetingPointController = TextEditingController(text: widget.event?.meetingPoint ?? '');
    _statusIdController = TextEditingController(text: widget.event?.statusId.toString() ?? '1');
    
    if (widget.event != null) {
      _selectedDate = widget.event!.eventDate;
      final timeParts = widget.event!.eventTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      _equipmentProvided = widget.event!.equipmentProvided;
      _adminApproved = widget.event!.adminApproved;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final eventTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
      
      if (widget.event == null) {
        // Create new event
        final request = EventInsertRequest(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          creatorUserId: int.parse(_creatorUserIdController.text),
          locationId: int.parse(_locationIdController.text),
          eventTypeId: int.parse(_eventTypeIdController.text),
          maxParticipants: int.parse(_maxParticipantsController.text),
          eventDate: _selectedDate,
          eventTime: eventTime,
          durationMinutes: int.parse(_durationMinutesController.text),
          equipmentProvided: _equipmentProvided,
          equipmentList: _equipmentListController.text.isEmpty ? null : _equipmentListController.text,
          meetingPoint: _meetingPointController.text.isEmpty ? null : _meetingPointController.text,
          statusId: int.parse(_statusIdController.text),
          adminApproved: _adminApproved,
        );
        await _eventProvider.insertEvent(request);
      } else {
        // Update existing event
        final request = EventUpdateRequest(
          id: widget.event!.id,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          creatorUserId: int.parse(_creatorUserIdController.text),
          locationId: int.parse(_locationIdController.text),
          eventTypeId: int.parse(_eventTypeIdController.text),
          maxParticipants: int.parse(_maxParticipantsController.text),
          eventDate: _selectedDate,
          eventTime: eventTime,
          durationMinutes: int.parse(_durationMinutesController.text),
          equipmentProvided: _equipmentProvided,
          equipmentList: _equipmentListController.text.isEmpty ? null : _equipmentListController.text,
          meetingPoint: _meetingPointController.text.isEmpty ? null : _meetingPointController.text,
          statusId: int.parse(_statusIdController.text),
          adminApproved: _adminApproved,
        );
        await _eventProvider.updateEvent(widget.event!.id, request);
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event == null ? 'Add Event' : 'Edit Event',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _creatorUserIdController,
                              decoration: const InputDecoration(
                                labelText: 'Creator User ID *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Creator User ID is required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationIdController,
                              decoration: const InputDecoration(
                                labelText: 'Location ID *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Location ID is required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _eventTypeIdController,
                              decoration: const InputDecoration(
                                labelText: 'Event Type ID *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Event Type ID is required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Event Date *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Event Time *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _maxParticipantsController,
                              decoration: const InputDecoration(
                                labelText: 'Max Participants *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Max participants is required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _durationMinutesController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (minutes) *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Duration is required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _meetingPointController,
                              decoration: const InputDecoration(
                                labelText: 'Meeting Point',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _statusIdController,
                              decoration: const InputDecoration(
                                labelText: 'Status ID *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Status ID is required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Equipment Provided'),
                              value: _equipmentProvided,
                              onChanged: (value) {
                                setState(() {
                                  _equipmentProvided = value ?? false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Admin Approved'),
                              value: _adminApproved,
                              onChanged: (value) {
                                setState(() {
                                  _adminApproved = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_equipmentProvided) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _equipmentListController,
                          decoration: const InputDecoration(
                            labelText: 'Equipment List',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.event == null ? 'Create' : 'Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _creatorUserIdController.dispose();
    _locationIdController.dispose();
    _eventTypeIdController.dispose();
    _maxParticipantsController.dispose();
    _durationMinutesController.dispose();
    _equipmentListController.dispose();
    _meetingPointController.dispose();
    _statusIdController.dispose();
    super.dispose();
  }
}
