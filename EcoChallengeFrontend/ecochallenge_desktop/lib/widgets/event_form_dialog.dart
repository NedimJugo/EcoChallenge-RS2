import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/event.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/providers/event_provider.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';

class EventFormDialog extends StatefulWidget {
  final EventResponse? event;
  final UserProvider userProvider;
  final VoidCallback onSaved;

  const EventFormDialog({
    Key? key,
    this.event,
    required this.userProvider,
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
  bool _isLoadingCreator = false;
  
  // Creator validation
  UserResponse? _selectedCreator;
  String? _creatorValidationError;
  List<UserResponse> _recentUsers = []; // Cache for recently searched users

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadRecentUsers();
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
      
      // Load creator data for existing event
      _loadCreatorData(widget.event!.creatorUserId);
    }
  }

  Future<void> _loadRecentUsers() async {
    try {
      final result = await widget.userProvider.get(
        filter: {'pageSize': 20, 'sortBy': 'Id', 'desc': true}
      );
      setState(() {
        _recentUsers = result.items ?? [];
      });
    } catch (e) {
      print('Failed to load recent users: $e');
    }
  }

  Future<void> _loadCreatorData(int creatorId) async {
    setState(() {
      _isLoadingCreator = true;
      _creatorValidationError = null;
    });

    try {
      final user = await widget.userProvider.getById(creatorId);
      setState(() {
        _selectedCreator = user;
        _creatorValidationError = null;
      });
    } catch (e) {
      setState(() {
        _selectedCreator = null;
        _creatorValidationError = 'User not found';
      });
    } finally {
      setState(() => _isLoadingCreator = false);
    }
  }

  Future<void> _validateCreatorId() async {
    final idText = _creatorUserIdController.text;
    if (idText.isEmpty) {
      setState(() {
        _selectedCreator = null;
        _creatorValidationError = null;
      });
      return;
    }

    final id = int.tryParse(idText);
    if (id == null) {
      setState(() {
        _selectedCreator = null;
        _creatorValidationError = 'Invalid ID format';
      });
      return;
    }

    await _loadCreatorData(id);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select event date',
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
      helpText: 'Select event time',
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Additional validation for creator
    if (_selectedCreator == null && _creatorUserIdController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid creator'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCreatorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _creatorUserIdController,
          decoration: InputDecoration(
            labelText: 'Creator User ID *',
            border: const OutlineInputBorder(),
            suffixIcon: _isLoadingCreator
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _selectedCreator != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : _creatorValidationError != null
                        ? const Icon(Icons.error, color: Colors.red)
                        : null,
            errorText: _creatorValidationError,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            // Debounce the validation
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_creatorUserIdController.text == value && value.isNotEmpty) {
                _validateCreatorId();
              }
            });
          },
          validator: (value) {
            if (value?.isEmpty == true) return 'Creator User ID is required';
            if (int.tryParse(value!) == null) return 'Must be a number';
            return null;
          },
        ),
        if (_selectedCreator != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedCreator!.firstName} ${_selectedCreator!.lastName} (${_selectedCreator!.username})',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_recentUsers.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Recent Users:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _recentUsers.take(5).map((user) {
              return InkWell(
                onTap: () {
                  _creatorUserIdController.text = user.id.toString();
                  setState(() {
                    _selectedCreator = user;
                    _creatorValidationError = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    '${user.firstName} ${user.lastName} (${user.id})',
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 750,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.event == null ? Icons.add_circle : Icons.edit,
                  color: Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.event == null ? 'Create New Event' : 'Edit Event',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Title and Creator ID row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event),
                              ),
                              validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildCreatorField(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Location and Event Type row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationIdController,
                              decoration: const InputDecoration(
                                labelText: 'Location ID *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
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
                                prefixIcon: Icon(Icons.category),
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
                      
                      // Date and Time row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Event Date *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
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
                                  prefixIcon: Icon(Icons.access_time),
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
                      
                      // Max Participants and Duration row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _maxParticipantsController,
                              decoration: const InputDecoration(
                                labelText: 'Max Participants *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.group),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Max participants is required';
                                final num = int.tryParse(value!);
                                if (num == null) return 'Must be a number';
                                if (num <= 0) return 'Must be greater than 0';
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
                                prefixIcon: Icon(Icons.timer),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Duration is required';
                                final num = int.tryParse(value!);
                                if (num == null) return 'Must be a number';
                                if (num <= 0) return 'Must be greater than 0';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Meeting Point and Status ID row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _meetingPointController,
                              decoration: const InputDecoration(
                                labelText: 'Meeting Point',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.place),
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
                                prefixIcon: Icon(Icons.info),
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
                      
                      // Checkboxes row
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 1,
                              child: CheckboxListTile(
                                title: const Text('Equipment Provided'),
                                subtitle: const Text('Check if equipment will be provided'),
                                value: _equipmentProvided,
                                onChanged: (value) {
                                  setState(() {
                                    _equipmentProvided = value ?? false;
                                  });
                                },
                                secondary: const Icon(Icons.build),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              elevation: 1,
                              child: CheckboxListTile(
                                title: const Text('Admin Approved'),
                                subtitle: const Text('Mark as approved by admin'),
                                value: _adminApproved,
                                onChanged: (value) {
                                  setState(() {
                                    _adminApproved = value ?? false;
                                  });
                                },
                                secondary: const Icon(Icons.admin_panel_settings),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Equipment List (conditional)
                      if (_equipmentProvided) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _equipmentListController,
                          decoration: const InputDecoration(
                            labelText: 'Equipment List',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.list),
                            hintText: 'List the equipment that will be provided...',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Saving...'),
                          ],
                        )
                      : Text(widget.event == null ? 'Create Event' : 'Update Event'),
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