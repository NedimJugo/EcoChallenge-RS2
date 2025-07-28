import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class CrudDialog<T> extends StatefulWidget {
  final T? item;
  final String title;
  final List<CrudField> fields;
  final Function(Map<String, dynamic>) onSave;

  const CrudDialog({
    Key? key,
    this.item,
    required this.title,
    required this.fields,
    required this.onSave,
  }) : super(key: key);

  @override
  _CrudDialogState<T> createState() => _CrudDialogState<T>();
}

class _CrudDialogState<T> extends State<CrudDialog<T>> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _values = {};
    
    for (var field in widget.fields) {
      if (field.type != CrudFieldType.date && 
          field.type != CrudFieldType.checkbox && 
          field.type != CrudFieldType.dropdown &&
          field.type != CrudFieldType.image) {
        _controllers[field.key] = TextEditingController(
          text: field.initialValue?.toString() ?? '',
        );
      }
      _values[field.key] = field.initialValue;
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        width: 500,
        constraints: BoxConstraints(maxHeight: 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.fields.map((field) => _buildField(field)).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(CrudField field) {
    switch (field.type) {
      case CrudFieldType.text:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(),
            ),
            validator: field.isRequired ? (value) {
              if (value == null || value.isEmpty) {
                return '${field.label} is required';
              }
              return null;
            } : null,
            onChanged: (value) => _values[field.key] = value,
          ),
        );
      case CrudFieldType.email:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (field.isRequired && (value == null || value.isEmpty)) {
                return '${field.label} is required';
              }
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Enter a valid email';
                }
              }
              return null;
            },
            onChanged: (value) => _values[field.key] = value,
          ),
        );
      case CrudFieldType.number:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: field.isRequired ? (value) {
              if (value == null || value.isEmpty) {
                return '${field.label} is required';
              }
              if (int.tryParse(value) == null) {
                return 'Enter a valid number';
              }
              return null;
            } : (value) {
              if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                return 'Enter a valid number';
              }
              return null;
            },
            onChanged: (value) => _values[field.key] = value.isNotEmpty ? int.tryParse(value) : null,
          ),
        );
      case CrudFieldType.date:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () => _selectDate(field.key),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: field.label,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _values[field.key] != null 
                    ? (_values[field.key] as DateTime).toString().split(' ')[0]
                    : 'Select date',
              ),
            ),
          ),
        );
      case CrudFieldType.checkbox:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: CheckboxListTile(
            title: Text(field.label),
            value: _values[field.key] ?? false,
            onChanged: (value) {
              setState(() {
                _values[field.key] = value ?? false;
              });
            },
          ),
        );
      case CrudFieldType.dropdown:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<dynamic>(
            value: _values[field.key],
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(),
            ),
            items: field.dropdownItems?.map((item) {
              return DropdownMenuItem<dynamic>(
                value: item.value,
                child: Text(item.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _values[field.key] = value;
              });
            },
            validator: field.isRequired ? (value) {
              if (value == null) {
                return '${field.label} is required';
              }
              return null;
            } : null,
          ),
        );
      case CrudFieldType.image:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _values[field.key] != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _values[field.key] is File
                                ? Image.file(
                                    _values[field.key] as File,
                                    width: double.infinity,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : _values[field.key] is String
                                    ? Image.network(
                                        _values[field.key] as String,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: Icon(Icons.broken_image, size: 40),
                                          );
                                        },
                                      )
                                    : Container(),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _values[field.key] = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: () => _pickImage(field.key),
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to select image', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
              ),
              if (_values[field.key] == null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(field.key),
                    icon: Icon(Icons.upload_file),
                    label: Text('Select Image'),
                  ),
                ),
            ],
          ),
        );
    }
  }

  Future<void> _selectDate(String fieldKey) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _values[fieldKey] as DateTime? ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _values[fieldKey] = picked;
      });
    }
  }

  Future<void> _pickImage(String fieldKey) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _values[fieldKey] = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_values);
      Navigator.of(context).pop();
    }
  }
}

class CrudField {
  final String key;
  final String label;
  final CrudFieldType type;
  final bool isRequired;
  final dynamic initialValue;
  final List<DropdownItem>? dropdownItems;

  CrudField({
    required this.key,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.initialValue,
    this.dropdownItems,
  });
}

class DropdownItem {
  final dynamic value;
  final String label;

  DropdownItem({required this.value, required this.label});
}

enum CrudFieldType {
  text,
  email,
  number,
  date,
  checkbox,
  dropdown,
  image,
}
