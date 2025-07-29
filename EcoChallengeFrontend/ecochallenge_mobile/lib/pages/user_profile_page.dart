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
  
  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  
  UserResponse? _user;
  List<BadgeResponse> _allBadges = [];
  List<UserBadgeResponse> _userBadges = [];
  List<BadgeResponse> _earnedBadges = [];
  
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final badgeProvider = Provider.of<BadgeProvider>(context, listen: false);
      final userBadgeProvider = Provider.of<UserBadgeProvider>(context, listen: false);
      
      // First, try to get the user from AuthProvider if it's the current user
      if (widget.userId == AuthProvider.userData?.id) {
        _user = AuthProvider.userData;
        _populateControllers();
      } else {
        // For other users, we need to fetch from API
        // Since your BaseProvider doesn't have a getById method, let's try with filter
        try {
          final userResult = await userProvider.get();
          if (userResult.items?.isNotEmpty == true) {
            // Find the user with matching ID
            _user = userResult.items!.firstWhere(
              (user) => user.id == widget.userId,
              orElse: () => throw Exception('User not found'),
            );
            _populateControllers();
          }
        } catch (e) {
          print('Error fetching user: $e');
          // If we can't fetch the user, show error
          throw Exception('Failed to load user data');
        }
      }
      
      // Load all badges and user badges
      _allBadges = await badgeProvider.getAllBadges();
      _userBadges = await userBadgeProvider.getAllUserBadges();
      
      // Filter earned badges for this user
      _earnedBadges = _allBadges.where((badge) {
        return _userBadges.any((userBadge) => 
          userBadge.userId == widget.userId && userBadge.badgeId == badge.id);
      }).toList();
      
    } catch (e) {
      print('Error in _loadUserData: $e');
      _showErrorSnackBar('Failed to load profile data: $e');
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
      _selectedDateOfBirth = _user!.dateOfBirth;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
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
    }
  }

  Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) return;
  
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
      userTypeId: _user?.userTypeId, // Add this line
    );
    
    UserResponse updatedUser;
    
    if (_selectedImage != null) {
      // Use the new updateWithFiles method when there's an image
      updatedUser = await userProvider.updateWithFiles(
        widget.userId,
        updateRequest,
        files: [_selectedImage!],
      );
    } else {
      // Use the overridden update method for regular updates
      updatedUser = await userProvider.update(widget.userId, updateRequest);
    }
    
    setState(() {
      _user = updatedUser;
      _isEditing = false;
      _selectedImage = null;
    });
    
    // Update AuthProvider if this is the current user
    if (widget.userId == AuthProvider.userData?.id) {
      AuthProvider.userData = updatedUser;
    }
    
    _showSuccessSnackBar('Profile updated successfully!');
    
  } catch (e) {
    print('Error saving profile: $e');
    _showErrorSnackBar('Failed to update profile: $e');
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
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isEditing && _user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
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
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildPointsCard(),
                        const SizedBox(height: 24),
                        _buildBioSection(),
                        const SizedBox(height: 24),
                        _buildProfileForm(),
                        const SizedBox(height: 24),
                        if (_isEditing) _buildActionButtons(),
                        if (!_isEditing) _buildEditButton(),
                        const SizedBox(height: 32),
                        _buildBadgesSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.orange[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : _user?.profileImageUrl != null
                          ? NetworkImage(_user!.profileImageUrl!)
                          : null,
                  child: _selectedImage == null && _user?.profileImageUrl == null
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
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
        children: [
          Text(
            'Points: ${_user?.totalPoints ?? 0}/200',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_user?.totalPoints ?? 0) / 200,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
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
          const Text(
            'Bio:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Passionate about nature and environmental sustainability. I love organizing cleanup events and inspiring others to make a positive impact on our planet.',
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  'Name:',
                  _firstNameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  'City:',
                  _cityController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  'Surname:',
                  _lastNameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Surname is required';
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
                      'Date of birth:',
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
          _buildFormField(
            'Email:',
            _emailController,
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
          _buildFormField(
            'Phone number:',
            _phoneController,
            validator: (value) {
              if (value?.isNotEmpty == true && value!.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          validator: validator,
          decoration: InputDecoration(
            border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          ),
          style: TextStyle(
            color: _isEditing ? Colors.black : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () {
              setState(() {
                _isEditing = false;
                _selectedImage = null;
                _populateControllers(); // Reset form
              });
            },
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
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => setState(() => _isEditing = true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Edit profile'),
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
          const Text(
            'Badges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _earnedBadges.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No badges earned yet',
                        style: TextStyle(
                          fontSize: 16,
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
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _earnedBadges.length,
                  itemBuilder: (context, index) {
                    final badge = _earnedBadges[index];
                    return _buildBadgeItem(badge);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(BadgeResponse badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange[100],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange[300]!, width: 2),
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
    );
  }

  Widget _buildDefaultBadgeIcon() {
    return const Icon(
      Icons.emoji_events,
      color: Colors.orange,
      size: 32,
    );
  }

  void _showBadgeDetails(BadgeResponse badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(badge.name ?? 'Badge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange[300]!, width: 2),
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
            const SizedBox(height: 16),
            if (badge.description != null)
              Text(
                badge.description!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}