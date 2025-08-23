import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecochallenge_desktop/models/organization.dart';
import 'package:ecochallenge_desktop/providers/organization_provider.dart';

class OrganizationFormDialog extends StatefulWidget {
  final OrganizationResponse? organization;
  final VoidCallback onSaved;

  const OrganizationFormDialog({
    super.key,
    this.organization,
    required this.onSaved,
  });

  @override
  State<OrganizationFormDialog> createState() => _OrganizationFormDialogState();
}

class _OrganizationFormDialogState extends State<OrganizationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final OrganizationProvider _organizationProvider = OrganizationProvider();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _websiteController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _categoryController;
  
  bool _isVerified = false;
  bool _isActive = true;
  bool _isLoading = false;
  File? _selectedLogoFile;
  String? _selectedLogoFileName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.organization?.name ?? '');
    _descriptionController = TextEditingController(text: widget.organization?.description ?? '');
    _websiteController = TextEditingController(text: widget.organization?.website ?? '');
    _contactEmailController = TextEditingController(text: widget.organization?.contactEmail ?? '');
    _contactPhoneController = TextEditingController(text: widget.organization?.contactPhone ?? '');
    _categoryController = TextEditingController(text: widget.organization?.category ?? '');
    
    if (widget.organization != null) {
      _isVerified = widget.organization!.isVerified;
      _isActive = widget.organization!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickLogoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedLogoFile = File(result.files.single.path!);
        _selectedLogoFileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveOrganization() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.organization == null) {
        // Create new organization
        final request = OrganizationInsertRequest(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          website: _websiteController.text.isEmpty ? null : _websiteController.text,
          logoImage: _selectedLogoFile,
          contactEmail: _contactEmailController.text.isEmpty ? null : _contactEmailController.text,
          contactPhone: _contactPhoneController.text.isEmpty ? null : _contactPhoneController.text,
          category: _categoryController.text.isEmpty ? null : _categoryController.text,
          isVerified: _isVerified,
          isActive: _isActive,
        );
        await _organizationProvider.insertOrganization(request);
      } else {
        // Update existing organization
        final request = OrganizationUpdateRequest(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          website: _websiteController.text.isEmpty ? null : _websiteController.text,
          logoImage: _selectedLogoFile,
          contactEmail: _contactEmailController.text.isEmpty ? null : _contactEmailController.text,
          contactPhone: _contactPhoneController.text.isEmpty ? null : _contactPhoneController.text,
          category: _categoryController.text.isEmpty ? null : _categoryController.text,
          isVerified: _isVerified,
          isActive: _isActive,
        );
        await _organizationProvider.updateOrganization(widget.organization!.id, request);
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving organization: $e')),
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
      title: Text(widget.organization == null ? 'Add Organization' : 'Edit Organization'),
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
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(_selectedLogoFileName ?? 'No logo selected'),
                    ),
                    ElevatedButton(
                      onPressed: _pickLogoFile,
                      child: const Text('Select Logo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Verified'),
                        value: _isVerified,
                        onChanged: (value) {
                          setState(() {
                            _isVerified = value ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value ?? true;
                          });
                        },
                      ),
                    ),
                  ],
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
          onPressed: _isLoading ? null : _saveOrganization,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.organization == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
