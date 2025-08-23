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
  bool _isPasswordVisible = false;
  DateTime? _selectedDateOfBirth;
  
  // Error messages for individual fields
  String? _usernameError;
  String? _emailError;
  String? _passwordError;

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

  // Check if username exists (excluding current user if editing)
  Future<bool> _checkUsernameExists(String username) async {
    try {
      final searchObject = UserSearchObject(
        username: username,
        pageSize: 1,
      );
      
      final result = await _userProvider.get(filter: searchObject.toJson());
      
      // If editing, exclude current user from check
      if (widget.user != null) {
        return result.items?.any((user) => user.id != widget.user!.id) ?? false;
      }
      
      return (result.items?.isNotEmpty ?? false);
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Check if email exists (excluding current user if editing)
  Future<bool> _checkEmailExists(String email) async {
    try {
      final searchObject = UserSearchObject(
        email: email,
        pageSize: 1,
      );
      
      final result = await _userProvider.get(filter: searchObject.toJson());
      
      // If editing, exclude current user from check
      if (widget.user != null) {
        return result.items?.any((user) => user.id != widget.user!.id) ?? false;
      }
      
      return (result.items?.isNotEmpty ?? false);
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  Future<void> _validateUniqueFields() async {
    setState(() {
      _usernameError = null;
      _emailError = null;
    });

    // Check username uniqueness
    if (_usernameController.text.isNotEmpty) {
      bool usernameExists = await _checkUsernameExists(_usernameController.text);
      if (usernameExists) {
        setState(() {
          _usernameError = 'Username already exists';
        });
      }
    }

    // Check email uniqueness
    if (_emailController.text.isNotEmpty) {
      bool emailExists = await _checkEmailExists(_emailController.text);
      if (emailExists) {
        setState(() {
          _emailError = 'Email already exists';
        });
      }
    }
  }

  Future<void> _saveUser() async {
    // Clear previous errors
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Validate unique fields
    await _validateUniqueFields();

    // Check if there are any validation errors
    if (_usernameError != null || _emailError != null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      if (widget.user == null) {
        // Create new user
        final request = UserInsertRequest(
          username: _usernameController.text,
          email: _emailController.text,
          passwordHash: _passwordController.text, // Backend handles hashing
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
        final Map<String, dynamic> requestData = {
          'username': _usernameController.text,
          'email': _emailController.text,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phoneNumber': _phoneController.text.isEmpty ? null : _phoneController.text,
          'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
          'city': _cityController.text.isEmpty ? null : _cityController.text,
          'country': _countryController.text.isEmpty ? null : _countryController.text,
          'userTypeId': _selectedUserType!.id,
          'isActive': _isActive,
        };

        // Only include password if it's provided
        if (_passwordController.text.isNotEmpty) {
          requestData['passwordHash'] = _passwordController.text;
        }

        await _userProvider.update(widget.user!.id, requestData);
      }
      
      widget.onSaved();
    } catch (e) {
      // Handle specific backend validation errors
      String errorMessage = 'Failed to save user: $e';
      
      if (e.toString().contains('username')) {
        setState(() {
          _usernameError = 'Username validation failed';
        });
      } else if (e.toString().contains('email')) {
        setState(() {
          _emailError = 'Email validation failed';
        });
      } else if (e.toString().contains('password')) {
        setState(() {
          _passwordError = 'Password validation failed';
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validatePassword(String? value) {
    if (widget.user == null && (value == null || value.isEmpty)) {
      return 'Password is required';
    }
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Username *',
                                    border: const OutlineInputBorder(),
                                    errorText: _usernameError,
                                  ),
                                  validator: (value) => value?.isEmpty == true ? 'Username is required' : null,
                                  onChanged: (value) {
                                    if (_usernameError != null) {
                                      setState(() {
                                        _usernameError = null;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email *',
                                    border: const OutlineInputBorder(),
                                    errorText: _emailError,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty == true) return 'Email is required';
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    if (_emailError != null) {
                                      setState(() {
                                        _emailError = null;
                                      });
                                    }
                                  },
                                ),
                              ],
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
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: widget.user == null ? 'Password *' : 'Password (leave empty to keep current)',
                              border: const OutlineInputBorder(),
                              errorText: _passwordError,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: _validatePassword,
                            onChanged: (value) {
                              if (_passwordError != null) {
                                setState(() {
                                  _passwordError = null;
                                });
                              }
                            },
                          ),
                        ],
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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