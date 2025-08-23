import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/event_type.dart';
import 'package:ecochallenge_desktop/providers/event_type_provider.dart';

class EventTypeFormDialog extends StatefulWidget {
  final EventTypeResponse? eventType;
  final VoidCallback onSaved;

  const EventTypeFormDialog({
    super.key,
    this.eventType,
    required this.onSaved,
  });

  @override
  State<EventTypeFormDialog> createState() => _EventTypeFormDialogState();
}

class _EventTypeFormDialogState extends State<EventTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final EventTypeProvider _eventTypeProvider = EventTypeProvider();
  
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.eventType?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveEventType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.eventType == null) {
        // Create new event type
        final request = EventTypeInsertRequest(
          name: _nameController.text,
        );
        await _eventTypeProvider.insert(request);
      } else {
        // Update existing event type
        final request = EventTypeUpdateRequest(
          id: widget.eventType!.id,
          name: _nameController.text,
        );
        await _eventTypeProvider.update(widget.eventType!.id, request);
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event type: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.eventType == null ? 'Add Event Type' : 'Edit Event Type'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveEventType,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.eventType == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
