import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecochallenge_desktop/models/badge.dart';
import 'package:ecochallenge_desktop/models/badge_type.dart';
import 'package:ecochallenge_desktop/providers/badge_provider.dart';

class BadgeFormDialog extends StatefulWidget {
  final BadgeResponse? badge;
  final List<BadgeTypeResponse> badgeTypes;
  final VoidCallback onSaved;

  const BadgeFormDialog({
    super.key,
    this.badge,
    required this.badgeTypes,
    required this.onSaved,
  });

  @override
  State<BadgeFormDialog> createState() => _BadgeFormDialogState();
}

class _BadgeFormDialogState extends State<BadgeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final BadgeProvider _badgeProvider = BadgeProvider();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _criteriaValueController;
  
  int? _selectedBadgeTypeId;
  int _selectedCriteriaTypeId = 1; // Default criteria type
  bool _isActive = true;
  bool _isLoading = false;
  File? _selectedIconFile;
  String? _selectedIconFileName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.badge?.name ?? '');
    _descriptionController = TextEditingController(text: widget.badge?.description ?? '');
    _criteriaValueController = TextEditingController(text: widget.badge?.criteriaValue.toString() ?? '');
    
    if (widget.badge != null) {
      _selectedBadgeTypeId = widget.badge!.badgeTypeId;
      _selectedCriteriaTypeId = widget.badge!.criteriaTypeId;
      _isActive = widget.badge!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _criteriaValueController.dispose();
    super.dispose();
  }

  Future<void> _pickIconFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedIconFile = File(result.files.single.path!);
        _selectedIconFileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveBadge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.badge == null) {
        // Create new badge
        final request = BadgeInsertRequest(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          badgeTypeId: _selectedBadgeTypeId!,
          criteriaTypeId: _selectedCriteriaTypeId,
          criteriaValue: int.parse(_criteriaValueController.text),
          isActive: _isActive,
        );
        await _badgeProvider.insertBadge(request, imageFile: _selectedIconFile);
      } else {
        // Update existing badge
        final request = BadgeUpdateRequest(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          badgeTypeId: _selectedBadgeTypeId,
          criteriaTypeId: _selectedCriteriaTypeId,
          criteriaValue: int.parse(_criteriaValueController.text),
          isActive: _isActive,
        );
        await _badgeProvider.updateBadge(widget.badge!.id, request, imageFile: _selectedIconFile);
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving badge: $e')),
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
      title: Text(widget.badge == null ? 'Add Badge' : 'Edit Badge'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                DropdownButtonFormField<int>(
                  value: _selectedBadgeTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Badge Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.badgeTypes.map((badgeType) => DropdownMenuItem(
                    value: badgeType.id,
                    child: Text(badgeType.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBadgeTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a badge type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _criteriaValueController,
                  decoration: const InputDecoration(
                    labelText: 'Criteria Value *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a criteria value';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(_selectedIconFileName ?? 'No icon selected'),
                    ),
                    ElevatedButton(
                      onPressed: _pickIconFile,
                      child: const Text('Select Icon'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBadge,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.badge == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
