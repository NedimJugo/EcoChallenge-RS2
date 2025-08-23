import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/models/user_type.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';

class UserFormDialog extends StatefulWidget {
  final UserResponse? user;
  final List<UserType> userTypes;
  final VoidCallback onSaved;

  const UserFormDialog({
    Key? key,
    this.user,
    required this.userTypes,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final UserProvider _userProvider = UserProvider();
  
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _passwordController;
  
  UserType? _selectedUserType;
  bool _isActive = true;
  bool _isLoading = false;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _firstNameController = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user?.lastName ?? '');
    _phoneController = TextEditingController(text: widget.user?.phoneNumber ?? '');
    _cityController = TextEditingController(text: widget.user?.city ?? '');
    _countryController = TextEditingController(text: widget.user?.country ?? '');
    _passwordController = TextEditingController();
    
    if (widget.user != null) {
      _isActive = widget.user!.isActive;
      _selectedDateOfBirth = widget.user!.dateOfBirth;
      _selectedUserType = widget.userTypes.firstWhere(
        (type) => type.id == widget.user!.userTypeId,
        orElse: () => widget.userTypes.first,
      );
    } else {
      _selectedUserType = widget.userTypes.isNotEmpty ? widget.userTypes.first : null;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.user == null) {
        // Create new user
        final request = UserInsertRequest(
          username: _usernameController.text,
          email: _emailController.text,
          passwordHash: _passwordController.text, // In real app, hash this
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
          dateOfBirth: _selectedDateOfBirth,
          city: _cityController.text.isEmpty ? null : _cityController.text,
          country: _countryController.text.isEmpty ? null : _countryController.text,
          userTypeId: _selectedUserType!.id,
          isActive: _isActive,
        );
        await _userProvider.insert(request.toJson());
      } else {
        // Update existing user
        final request = UserUpdateRequest(
          username: _usernameController.text,
          email: _emailController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
          dateOfBirth: _selectedDateOfBirth,
          city: _cityController.text.isEmpty ? null : _cityController.text,
          country: _countryController.text.isEmpty ? null : _countryController.text,
          userTypeId: _selectedUserType!.id,
          isActive: _isActive,
        );
        await _userProvider.update(widget.user!.id, request.toJson());
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user: $e'), backgroundColor: Colors.red),
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user == null ? 'Add New User' : 'Edit User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty == true ? 'Username is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Email is required';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                  return 'Enter a valid email';
                                }
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
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty == true ? 'First name is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty == true ? 'Last name is required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: widget.user == null ? 'Password *' : 'Password (leave empty to keep current)',
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: widget.user == null 
                            ? (value) => value?.isEmpty == true ? 'Password is required' : null
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedDateOfBirth != null
                                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                      : 'Select date',
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
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _countryController,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<UserType>(
                              value: _selectedUserType,
                              decoration: const InputDecoration(
                                labelText: 'User Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: widget.userTypes.map((userType) {
                                return DropdownMenuItem(
                                  value: userType,
                                  child: Text(userType.name),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedUserType = value),
                              validator: (value) => value == null ? 'User type is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Active'),
                              value: _isActive,
                              onChanged: (value) => setState(() => _isActive = value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                    onPressed: _isLoading ? null : _saveUser,
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
                        : Text(widget.user == null ? 'Create' : 'Update'),
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
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
