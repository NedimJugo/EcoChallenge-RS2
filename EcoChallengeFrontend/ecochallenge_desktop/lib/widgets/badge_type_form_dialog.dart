import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/badge_type.dart';
import 'package:ecochallenge_desktop/providers/badge_type_provider.dart';

class BadgeTypeFormDialog extends StatefulWidget {
  final BadgeTypeResponse? badgeType;
  final VoidCallback onSaved;

  const BadgeTypeFormDialog({
    super.key,
    this.badgeType,
    required this.onSaved,
  });

  @override
  State<BadgeTypeFormDialog> createState() => _BadgeTypeFormDialogState();
}

class _BadgeTypeFormDialogState extends State<BadgeTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final BadgeTypeProvider _badgeTypeProvider = BadgeTypeProvider();
  
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.badgeType?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveBadgeType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.badgeType == null) {
        // Create new badge type
        final request = BadgeTypeInsertRequest(
          name: _nameController.text,
        );
        await _badgeTypeProvider.insertBadgeType(request);
      } else {
        // Update existing badge type
        final request = BadgeTypeUpdateRequest(
          id: widget.badgeType!.id,
          name: _nameController.text,
        );
        await _badgeTypeProvider.updateBadgeType(widget.badgeType!.id, request);
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving badge type: $e')),
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
      title: Text(widget.badgeType == null ? 'Add Badge Type' : 'Edit Badge Type'),
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
          onPressed: _isLoading ? null : _saveBadgeType,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.badgeType == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
