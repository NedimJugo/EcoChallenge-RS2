import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/user_type.dart';
import 'package:ecochallenge_desktop/providers/user_type_provider.dart';

class UserTypeFormDialog extends StatefulWidget {
  final UserType? userType;
  final VoidCallback onSaved;

  const UserTypeFormDialog({
    Key? key,
    this.userType,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<UserTypeFormDialog> createState() => _UserTypeFormDialogState();
}

class _UserTypeFormDialogState extends State<UserTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final UserTypeProvider _userTypeProvider = UserTypeProvider();
  
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userType?.name ?? '');
  }

  Future<void> _saveUserType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = UserTypeRequest(name: _nameController.text);
      
      if (widget.userType == null) {
        await _userTypeProvider.insert(request.toJson());
      } else {
        await _userTypeProvider.update(widget.userType!.id, request.toJson());
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user type: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userType == null ? 'Add New User Type' : 'Edit User Type',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveUserType,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.userType == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
