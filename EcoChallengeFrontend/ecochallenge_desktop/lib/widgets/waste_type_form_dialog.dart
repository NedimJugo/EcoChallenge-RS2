import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/waste_type.dart';
import 'package:ecochallenge_desktop/providers/waste_type_provider.dart';

class WasteTypeFormDialog extends StatefulWidget {
  final WasteTypeResponse? wasteType;
  final VoidCallback onSaved;

  const WasteTypeFormDialog({
    super.key,
    this.wasteType,
    required this.onSaved,
  });

  @override
  State<WasteTypeFormDialog> createState() => _WasteTypeFormDialogState();
}

class _WasteTypeFormDialogState extends State<WasteTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final WasteTypeProvider _wasteTypeProvider = WasteTypeProvider();
  
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wasteType?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveWasteType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.wasteType == null) {
        // Create new waste type
        final request = WasteTypeInsertRequest(
          name: _nameController.text,
        );
        await _wasteTypeProvider.insert(request);
      } else {
        // Update existing waste type
        final request = WasteTypeUpdateRequest(
          name: _nameController.text,
        );
        await _wasteTypeProvider.update(widget.wasteType!.id, request);
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving waste type: $e')),
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
      title: Text(widget.wasteType == null ? 'Add Waste Type' : 'Edit Waste Type'),
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
          onPressed: _isLoading ? null : _saveWasteType,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.wasteType == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
