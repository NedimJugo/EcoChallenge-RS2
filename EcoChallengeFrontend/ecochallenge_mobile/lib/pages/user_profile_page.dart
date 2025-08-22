import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Import your models and providers
import 'package:ecochallenge_mobile/models/user.dart';
import 'package:ecochallenge_mobile/models/badge.dart';
import 'package:ecochallenge_mobile/models/user_badge.dart';
import 'package:ecochallenge_mobile/providers/user_provider.dart';
import 'package:ecochallenge_mobile/providers/badge_provider.dart';
import 'package:ecochallenge_mobile/providers/user_badge_provider.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  final bool isCurrentUser; // Add this to distinguish current user vs others
  
  const UserProfilePage({
    Key? key, 
    required this.userId,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isImageUploading = false;
  
  UserResponse? _user;
  List<BadgeResponse> _allBadges = [];
  List<UserBadgeResponse> _userBadges = [];
  List<BadgeResponse> _earnedBadges = [];
  
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _bioController; // Add bio controller
  DateTime? _selectedDateOfBirth;

    // Validation states and error messages
  Map<String, String?> _fieldErrors = {};
  Map<String, bool> _fieldValidating = {};
  
  // Validation timers to debounce API calls
  Map<String, Timer?> _validationTimers = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    _bioController = TextEditingController();

     _usernameController.addListener(() => _validateField('username'));
    _emailController.addListener(() => _validateField('email'));
    _phoneController.addListener(() => _validateField('phone'));
    _firstNameController.addListener(() => _validateField('firstName'));
    _lastNameController.addListener(() => _validateField('lastName'));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();

    _validationTimers.values.forEach((timer) => timer?.cancel());
    super.dispose();
  }

   void _validateField(String fieldName) {
    if (!_isEditing) return;

    // Cancel previous timer for this field
    _validationTimers[fieldName]?.cancel();
    
    // Set a new timer to debounce validation
    _validationTimers[fieldName] = Timer(const Duration(milliseconds: 800), () {
      _performFieldValidation(fieldName);
    });
  }

   Future<void> _performFieldValidation(String fieldName) async {
    if (!mounted) return;

    setState(() {
      _fieldValidating[fieldName] = true;
      _fieldErrors[fieldName] = null;
    });

    String? error;

    try {
      switch (fieldName) {
        case 'username':
          error = await _validateUsername(_usernameController.text);
          break;
        case 'email':
          error = await _validateEmail(_emailController.text);
          break;
        case 'phone':
          error = _validatePhone(_phoneController.text);
          break;
        case 'firstName':
          error = _validateFirstName(_firstNameController.text);
          break;
        case 'lastName':
          error = _validateLastName(_lastNameController.text);
          break;
      }
    } catch (e) {
      error = 'Validation error occurred';
      print('Validation error for $fieldName: $e');
    }

    if (mounted) {
      setState(() {
        _fieldValidating[fieldName] = false;
        _fieldErrors[fieldName] = error;
      });
    }
  }

  Future<String?> _validateUsername(String username) async {
    if (username.isEmpty) {
      return 'Username is required';
    }
    
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }

    // Check for valid characters (alphanumeric and underscore only)
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    // Skip API call if username hasn't changed
    if (_user?.username == username) {
      return null;
    }

    // Check if username exists (API call)
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final searchObj = UserSearchObject(username: username, pageSize: 1);
      final result = await userProvider.get(filter: searchObj.toJson());
      
      if (result.items?.isNotEmpty == true) {
        return 'Username already exists';
      }
    } catch (e) {
      print('Error checking username availability: $e');
      // Don't show error to user for API failures during validation
    }

    return null;
  }

  Future<String?> _validateEmail(String email) async {
    if (email.isEmpty) {
      return 'Email is required';
    }

    // Basic email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Skip API call if email hasn't changed
    if (_user?.email == email) {
      return null;
    }

    // Check if email exists (API call)
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final searchObj = UserSearchObject(email: email, pageSize: 1);
      final result = await userProvider.get(filter: searchObj.toJson());
      
      if (result.items?.isNotEmpty == true) {
        return 'Email address already exists';
      }
    } catch (e) {
      print('Error checking email availability: $e');
      // Don't show error to user for API failures during validation
    }

    return null;
  }

  String? _validatePhone(String phone) {
    if (phone.isEmpty) return null; // Phone is optional
    
    // Remove all non-digit characters for validation
    String digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }

    return null;
  }

  String? _validateFirstName(String firstName) {
    if (firstName.isEmpty) {
      return 'First name is required';
    }

    if (firstName.length < 2) {
      return 'First name must be at least 2 characters';
    }

    if (firstName.length > 50) {
      return 'First name must be less than 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-\']+$").hasMatch(firstName)) {
      return 'First name can only contain letters, spaces, hyphens, and apostrophes';
    }


    return null;
  }

  String? _validateLastName(String lastName) {
    if (lastName.isEmpty) {
      return 'Last name is required';
    }

    if (lastName.length < 2) {
      return 'Last name must be at least 2 characters';
    }

    if (lastName.length > 50) {
      return 'Last name must be less than 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-\']+$").hasMatch(lastName)) {
      return 'Last name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Check if form has any validation errors
  bool _hasValidationErrors() {
    return _fieldErrors.values.any((error) => error != null) ||
           _fieldValidating.values.any((validating) => validating == true);
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final badgeProvider = Provider.of<BadgeProvider>(context, listen: false);
      final userBadgeProvider = Provider.of<UserBadgeProvider>(context, listen: false);
      
      // Use the new getUserById method for better performance
      _user = await userProvider.getUserById(widget.userId);
      
      if (_user == null) {
        throw Exception('User not found');
      }
      
      _populateControllers();
      
      // Load badges data in parallel for better performance
      final futures = await Future.wait([
        badgeProvider.getAllBadges(),
        userBadgeProvider.getAllUserBadges(),
      ]);
      
      _allBadges = futures[0] as List<BadgeResponse>;
      _userBadges = futures[1] as List<UserBadgeResponse>;
      
      // Filter earned badges for this user
      _earnedBadges = _allBadges.where((badge) {
        return _userBadges.any((userBadge) => 
          userBadge.userId == widget.userId && userBadge.badgeId == badge.id);
      }).toList();
      
      _animationController.forward();
      
    } catch (e) {
      print('Error in _loadUserData: $e');
      _showErrorSnackBar('Failed to load profile data: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  

  void _populateControllers() {
    if (_user != null) {
      _firstNameController.text = _user!.firstName;
      _lastNameController.text = _user!.lastName;
      _usernameController.text = _user!.username;
      _emailController.text = _user!.email;
      _phoneController.text = _user!.phoneNumber ?? '';
      _cityController.text = _user!.city ?? '';
      _countryController.text = _user!.country ?? '';
      // Add bio field (you may need to add this to your UserResponse model)
      // _bioController.text = _user!.bio ?? '';
      _selectedDateOfBirth = _user!.dateOfBirth;
    }
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectImage(ImageSource.camera);
                  },
                ),
                if (_selectedImage != null || _user?.profileImageUrl != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Image'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        // You might want to handle removing the current image
                      });
                    },
                  ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      _showErrorSnackBar('Failed to show image picker: $e');
    }
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      setState(() => _isImageUploading = true);
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    } finally {
      setState(() => _isImageUploading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
     if (_hasValidationErrors()) {
      _showErrorSnackBar('Please fix validation errors before saving');
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final updateRequest = UserUpdateRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
        dateOfBirth: _selectedDateOfBirth,
        userTypeId: _user?.userTypeId,
      );
      
      UserResponse updatedUser;
      
      if (_selectedImage != null) {
        updatedUser = await userProvider.updateWithFiles(
          widget.userId,
          updateRequest,
          files: [_selectedImage!],
        );
      } else {
        updatedUser = await userProvider.update(widget.userId, updateRequest);
      }
      
      setState(() {
        _user = updatedUser;
        _isEditing = false;
        _selectedImage = null;
        _fieldErrors.clear();
        _fieldValidating.clear();
      });
      
      // Update AuthProvider if this is the current user
      if (widget.isCurrentUser || widget.userId == AuthProvider.userData?.id) {
        AuthProvider.userData = updatedUser;
      }
      
      _showSuccessSnackBar('Profile updated successfully!');
      
    } catch (e) {
      print('Error saving profile: $e');
      _showErrorSnackBar('Failed to update profile: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Add method to show confirmation dialog
  Future<bool> _showDiscardChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _onWillPop() async {
    if (_isEditing) {
      return await _showDiscardChangesDialog();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Check if current user can edit this profile
    final canEdit = widget.isCurrentUser || 
                   (AuthProvider.userData?.id == widget.userId);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(canEdit ? 'My Profile' : 'Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            if (!_isEditing && _user != null && canEdit)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? _buildUserNotFoundWidget()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: RefreshIndicator(
                      onRefresh: _loadUserData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildProfileHeader(),
                              const SizedBox(height: 24),
                              _buildStatsCards(),
                              const SizedBox(height: 24),
                              _buildBioSection(),
                              const SizedBox(height: 24),
                              if (canEdit) _buildProfileForm(),
                              if (canEdit) const SizedBox(height: 24),
                              if (_isEditing && canEdit) _buildActionButtons(),
                              if (!_isEditing && canEdit) _buildEditButton(),
                              const SizedBox(height: 32),
                              _buildBadgesSection(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildUserNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'User not found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[300]!, Colors.orange[400]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: Stack(
              children: [
                Hero(
                  tag: 'profile_${widget.userId}',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _user?.profileImageUrl != null
                            ? NetworkImage(_user!.profileImageUrl!)
                            : null,
                    child: _selectedImage == null && _user?.profileImageUrl == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                ),
                if (_isImageUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                if (_isEditing && !_isImageUploading)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_user!.firstName} ${_user!.lastName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '@${_user!.username}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          'Points',
          '${_user?.totalPoints ?? 0}',
          Icons.star,
          Colors.purple,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          'Cleanups',
          '${_user?.totalCleanups ?? 0}',
          Icons.cleaning_services,
          Colors.green,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          'Events',
          '${_user?.totalEventsParticipated ?? 0}',
          Icons.event,
          Colors.blue,
        )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Bio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditing)
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tell us about yourself...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            )
          else
            Text(
              _bioController.text.isEmpty 
                  ? 'Passionate about nature and environmental sustainability. I love organizing cleanup events and inspiring others to make a positive impact on our planet.'
                  : _bioController.text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  'First Name',
                  _firstNameController,
                  fieldName: 'firstName',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  'Last Name',
                  _lastNameController,
                  fieldName: 'lastName', 
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormField(
            'Username',
            _usernameController,
            fieldName: 'username',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Username is required';
              }
              if (value!.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            'Email',
            _emailController,
            fieldName: 'email',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  'Phone Number',
                  _phoneController,
                  fieldName: 'phone',
                  validator: (value) {
                    if (value?.isNotEmpty == true && value!.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _isEditing ? _selectDateOfBirth : null,
                  child: AbsorbPointer(
                    child: _buildFormField(
                      'Date of Birth',
                      fieldName: 'dateOfBirth',
                      TextEditingController(
                        text: _selectedDateOfBirth != null
                            ? DateFormat('dd.MM.yyyy').format(_selectedDateOfBirth!)
                            : '',
                      ),
                      suffixIcon: _isEditing ? Icons.calendar_today : null,
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
                child: _buildFormField('City', _cityController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField('Country', _countryController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    IconData? suffixIcon,
    String? fieldName,
  }) {
    final hasError = _fieldErrors[fieldName] != null;
    final isValidating = _fieldValidating[fieldName] == true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          validator: validator,
          decoration: InputDecoration(
            border: _isEditing 
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : Colors.grey[300]!,
                    ),
                  )
                : const UnderlineInputBorder(),
            focusedBorder: _isEditing 
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : Colors.green, 
                      width: 2
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : Colors.green,
                    ),
                  ),
            errorBorder: _isEditing 
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  )
                : const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: _buildSuffixIcon(suffixIcon, isValidating, hasError),
            errorText: _fieldErrors[fieldName],
          ),
          style: TextStyle(
            color: _isEditing ? Colors.black : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  Widget? _buildSuffixIcon(IconData? suffixIcon, bool isValidating, bool hasError) {
    if (isValidating) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }
    
    if (hasError) {
      return const Icon(Icons.error, color: Colors.red);
    }
    
    if (_fieldErrors.containsKey(_getFieldNameFromIcon(suffixIcon)) && 
        _fieldErrors[_getFieldNameFromIcon(suffixIcon)] == null &&
        !isValidating) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    
    if (suffixIcon != null) {
      return Icon(suffixIcon, color: Colors.grey);
    }
    
    return null;
  }

   String? _getFieldNameFromIcon(IconData? icon) {
    // Helper method to map icons to field names for validation status
    if (icon == Icons.calendar_today) return null; // Date picker doesn't need validation icon
    return null;
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () async {
              if (_isEditing) {
                final shouldDiscard = await _showDiscardChangesDialog();
                if (shouldDiscard) {
                  setState(() {
                    _isEditing = false;
                    _selectedImage = null;
                    _populateControllers(); // Reset form
                  });
                }
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 2,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _isEditing = true),
        icon: const Icon(Icons.edit, size: 18),
        label: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 24, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_earnedBadges.length} earned',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _earnedBadges.isEmpty
              ? _buildNoBadgesWidget()
              : Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _earnedBadges.length,
                      itemBuilder: (context, index) {
                        final badge = _earnedBadges[index];
                        return _buildBadgeItem(badge);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => _showAllBadgesDialog(),
                      icon: const Icon(Icons.view_list, size: 18),
                      label: const Text('View All Badges'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildNoBadgesWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No badges earned yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete challenges to earn your first badge!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(BadgeResponse badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Hero(
        tag: 'badge_${badge.id}',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[200]!,
                Colors.orange[300]!,
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange[400]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: badge.iconUrl != null
              ? ClipOval(
                  child: Image.network(
                    badge.iconUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: Colors.orange,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultBadgeIcon();
                    },
                  ),
                )
              : _buildDefaultBadgeIcon(),
        ),
      ),
    );
  }

  Widget _buildDefaultBadgeIcon() {
    return const Center(
      child: Icon(
        Icons.emoji_events,
        color: Colors.orange,
        size: 32,
      ),
    );
  }

  void _showBadgeDetails(BadgeResponse badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                badge.name ?? 'Achievement Badge',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'badge_${badge.id}',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange[200]!,
                      Colors.orange[300]!,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange[400]!, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: badge.iconUrl != null
                    ? ClipOval(
                        child: Image.network(
                          badge.iconUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultBadgeIcon();
                          },
                        ),
                      )
                    : _buildDefaultBadgeIcon(),
              ),
            ),
            const SizedBox(height: 20),
            if (badge.description != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge.description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange[700],
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAllBadgesDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(
            maxHeight: 500,
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'All Achievements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _earnedBadges.length,
                  itemBuilder: (context, index) {
                    final badge = _earnedBadges[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: badge.iconUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  badge.iconUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.emoji_events,
                                      color: Colors.orange,
                                      size: 20,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.emoji_events,
                                color: Colors.orange,
                                size: 20,
                              ),
                      ),
                      title: Text(
                        badge.name ?? 'Achievement Badge',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: badge.description != null
                          ? Text(
                              badge.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        _showBadgeDetails(badge);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}