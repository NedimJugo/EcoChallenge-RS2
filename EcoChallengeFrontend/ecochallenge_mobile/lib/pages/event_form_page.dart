import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/custom_background.dart';
import '../widgets/osm_map_widget.dart';
import '../widgets/simple_map_fallback.dart';
import 'map_selection_page.dart';

class EventFormPage extends StatefulWidget {
  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _useMapFallback = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _requiredEquipmentController = TextEditingController();
  final _meetingPointController = TextEditingController();

  Map<String, String?> _validationErrors = {};

  // Form data
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<File> _selectedImages = [];
  double? _selectedLat;
  double? _selectedLng;
  bool _equipmentProvided = false;
  bool _isCreatingLocation = false;

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.trim().length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Please enter a valid address';
    }
    return null;
  }

  String? _validateMaxParticipants(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Max participants is required';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 1) {
      return 'Must be at least 1 participant';
    }
    if (number > 1000) {
      return 'Maximum 1000 participants allowed';
    }
    return null;
  }

  bool _validateDateTime() {
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    return selectedDateTime.isAfter(DateTime.now().add(Duration(hours: 1)));
  }

  bool _validateCurrentPage() {
    setState(() {
      _validationErrors.clear();
    });

    switch (_currentPage) {
      case 0: // Event Info Page
        final titleError = _validateTitle(_titleController.text);
        final descError = _validateDescription(_descriptionController.text);
        
        if (titleError != null) _validationErrors['title'] = titleError;
        if (descError != null) _validationErrors['description'] = descError;
        
        return _validationErrors.isEmpty;

      case 1: // Location Page
        final addressError = _validateAddress(_addressController.text);
        
        if (addressError != null) _validationErrors['address'] = addressError;
        if (_selectedLat == null || _selectedLng == null) {
          _validationErrors['location'] = 'Please select a location on the map';
        }
        
        return _validationErrors.isEmpty;

      case 2: // Event Details Page
        final participantsError = _validateMaxParticipants(_maxParticipantsController.text);
        
        if (participantsError != null) _validationErrors['participants'] = participantsError;
        if (!_validateDateTime()) {
          _validationErrors['datetime'] = 'Event must be scheduled at least 1 hour in the future';
        }
        
        return _validationErrors.isEmpty;

      case 3: // Photos Page (optional)
        return true;

      case 4: // Review Page
        return true;

      default:
        return true;
    }
  }

  InputDecoration _buildInputDecoration(String hintText, {String? errorText, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Color(0xFF2D5016)) : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF2D5016), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      errorText: errorText,
      errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 12),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Color(0xFF2D5016)),
                          onPressed: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Create Event',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5016),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    SizedBox(height: 12),
                    // Progress indicator
                    Row(
                      children: List.generate(5, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentPage 
                                  ? Color(0xFF2D5016) 
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildEventInfoPage(),
                    _buildLocationPage(),
                    _buildEventDetailsPage(),
                    _buildPhotosPage(),
                    _buildReviewPage(),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D5016), Color(0xFF4A7C2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2D5016).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  'Every good party\nhas a name!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'What\'s the scoop? Be as detailed as your grandma\'s stew recipe.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 30),
          
          Text(
            'Event Title *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            decoration: _buildInputDecoration(
              'Enter event title',
              errorText: _validationErrors['title'],
              prefixIcon: Icons.title,
            ),
            onChanged: (value) {
              if (_validationErrors['title'] != null) {
                setState(() {
                  _validationErrors['title'] = _validateTitle(value);
                });
              }
            },
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Description *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: _buildInputDecoration(
              'Describe your event in detail...',
              errorText: _validationErrors['description'],
              prefixIcon: Icons.description,
            ),
            onChanged: (value) {
              if (_validationErrors['description'] != null) {
                setState(() {
                  _validationErrors['description'] = _validateDescription(value);
                });
              }
            },
          ),
          
          SizedBox(height: 40),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_validateCurrentPage()) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Color(0xFF2D5016).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2D5016).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF2D5016), size: 28),
                SizedBox(width: 12),
                Text(
                  'Event Location',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5016),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          Text(
            'Address *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            decoration: _buildInputDecoration(
              'Enter event address',
              errorText: _validationErrors['address'],
              prefixIcon: Icons.home,
            ),
            onChanged: (value) {
              if (_validationErrors['address'] != null) {
                setState(() {
                  _validationErrors['address'] = _validateAddress(value);
                });
              }
            },
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Meeting Point',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _meetingPointController,
            decoration: _buildInputDecoration(
              'e.g., Main entrance, parking lot, etc.',
              prefixIcon: Icons.place,
            ),
          ),
          
          SizedBox(height: 24),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _validationErrors['location'] != null 
                    ? Colors.red 
                    : Color(0xFF2D5016).withOpacity(0.2)
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.map, color: Color(0xFF2D5016)),
                    SizedBox(width: 8),
                    Text(
                      'Location on Map *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5016),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapSelectionPage(
                              initialLat: _selectedLat,
                              initialLng: _selectedLng,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedLat = result['lat'];
                            _selectedLng = result['lng'];
                            _addressController.text = result['address'];
                            _validationErrors.remove('location');
                          });
                        }
                      },
                      icon: Icon(Icons.fullscreen, size: 18),
                      label: Text('Select'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2D5016),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  height: 180,
                  child: _buildMapWidget(),
                ),
                if (_validationErrors['location'] != null) ...[
                  SizedBox(height: 8),
                  Text(
                    _validationErrors['location']!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: 40),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_validateCurrentPage()) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Color(0xFF2D5016).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget() {
    if (_selectedLat == null || _selectedLng == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Colors.grey.shade400),
              SizedBox(height: 12),
              Text(
                'Tap "Select" to choose location',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Try to use OSM map, fallback to simple map if it fails
    try {
      if (_useMapFallback) {
        return SimpleMapFallback(
          latitude: _selectedLat!,
          longitude: _selectedLng!,
          isInteractive: true,
          zoom: 15.0,
          onLocationSelected: (lat, lng) {
            setState(() {
              _selectedLat = lat;
              _selectedLng = lng;
            });
          },
        );
      } else {
        return OSMMapWidget(
          latitude: _selectedLat!,
          longitude: _selectedLng!,
          isInteractive: true,
          zoom: 15.0,
          onLocationSelected: (lat, lng) {
            setState(() {
              _selectedLat = lat;
              _selectedLng = lng;
            });
          },
        );
      }
    } catch (e) {
      // Fallback to simple map if OSM fails
      setState(() {
        _useMapFallback = true;
      });
      return SimpleMapFallback(
        latitude: _selectedLat!,
        longitude: _selectedLng!,
        isInteractive: true,
        zoom: 15.0,
        onLocationSelected: (lat, lng) {
          setState(() {
            _selectedLat = lat;
            _selectedLng = lng;
          });
        },
      );
    }
  }

  Widget _buildEventDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2D5016).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_note, color: Color(0xFF2D5016), size: 28),
                SizedBox(width: 12),
                Text(
                  'Event Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5016),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5016),
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Color(0xFF2D5016)),
                            SizedBox(width: 12),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5016),
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Color(0xFF2D5016)),
                            SizedBox(width: 12),
                            Text(
                              '${_selectedTime.format(context)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_validationErrors['datetime'] != null) ...[
            SizedBox(height: 8),
            Text(
              _validationErrors['datetime']!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ],
          
          SizedBox(height: 20),
          
          Text(
            'Max. Participants *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _maxParticipantsController,
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration(
              'Enter maximum number of participants',
              errorText: _validationErrors['participants'],
              prefixIcon: Icons.group,
            ),
            onChanged: (value) {
              if (_validationErrors['participants'] != null) {
                setState(() {
                  _validationErrors['participants'] = _validateMaxParticipants(value);
                });
              }
            },
          ),
          
          SizedBox(height: 24),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2D5016).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.build, color: Color(0xFF2D5016)),
                    SizedBox(width: 8),
                    Text(
                      'Equipment Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5016),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _equipmentProvided,
                      onChanged: (value) {
                        setState(() {
                          _equipmentProvided = value ?? false;
                        });
                      },
                      activeColor: Color(0xFF2D5016),
                    ),
                    Expanded(
                      child: Text(
                        'Equipment will be provided',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _requiredEquipmentController,
                  maxLines: 3,
                  decoration: _buildInputDecoration(
                    _equipmentProvided 
                        ? 'List equipment that will be provided...'
                        : 'List equipment participants should bring...',
                    prefixIcon: Icons.inventory,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 40),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_validateCurrentPage()) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Color(0xFF2D5016).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2D5016).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.photo_camera, color: Color(0xFF2D5016), size: 28),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Photos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5016),
                      ),
                    ),
                    Text(
                      'Add photos to showcase your event',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF2D5016).withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _selectedImages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFF2D5016).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Color(0xFF2D5016),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tap to add photos',
                            style: TextStyle(
                              color: Color(0xFF2D5016),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Photos help attract more participants',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF2D5016).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xFF2D5016).withOpacity(0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Color(0xFF2D5016),
                                size: 32,
                              ),
                            ),
                          );
                        }
                        
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          
          if (_selectedImages.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2D5016).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2D5016), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${_selectedImages.length} photo${_selectedImages.length == 1 ? '' : 's'} selected',
                    style: TextStyle(
                      color: Color(0xFF2D5016),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 40),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Color(0xFF2D5016).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D5016), Color(0xFF4A7C2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2D5016).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.preview, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Your Event',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Check all details before submitting',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewItem('Title', _titleController.text, Icons.title),
                _buildReviewItem('Description', _descriptionController.text, Icons.description),
                _buildReviewItem('Address', _addressController.text, Icons.location_on),
                _buildReviewItem('Meeting Point', _meetingPointController.text, Icons.place),
                _buildReviewItem('Date', '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', Icons.calendar_today),
                _buildReviewItem('Time', _selectedTime.format(context), Icons.access_time),
                _buildReviewItem('Max Participants', _maxParticipantsController.text, Icons.group),
                _buildReviewItem('Equipment Provided', _equipmentProvided ? 'Yes' : 'No', Icons.build),
                _buildReviewItem('Equipment Details', _requiredEquipmentController.text, Icons.inventory),
                _buildReviewItem('Photos', '${_selectedImages.length} selected', Icons.photo_camera),
                
                if (_selectedLat != null && _selectedLng != null) ...[
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D5016).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.map, color: Color(0xFF2D5016)),
                            SizedBox(width: 8),
                            Text(
                              'Location Preview:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5016),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildMapWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: 30),
          
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isCreatingLocation ? null : _submitEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D5016),
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: Color(0xFF2D5016).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: _isCreatingLocation
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Creating Event...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Submit Event',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF2D5016), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5016),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not specified' : value,
                  style: TextStyle(
                    color: value.isEmpty ? Colors.grey.shade600 : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2D5016),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _validationErrors.remove('datetime');
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2D5016),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _validationErrors.remove('datetime');
      });
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Add Photos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5016),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2D5016).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: Color(0xFF2D5016)),
              ),
              title: Text(
                'Take Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Use camera to take a new photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    _selectedImages.add(File(image.path));
                  });
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2D5016).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo_library, color: Color(0xFF2D5016)),
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Select photos from your gallery'),
              onTap: () async {
                Navigator.pop(context);
                final List<XFile>? images = await picker.pickMultiImage(
                  imageQuality: 80,
                );
                if (images != null) {
                  setState(() {
                    _selectedImages.addAll(images.map((image) => File(image.path)));
                  });
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEvent() async {
    if (!_validateCurrentPage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please check all required fields'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter a title'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off, color: Colors.white),
              SizedBox(width: 8),
              Text('Please select a location on the map'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isCreatingLocation = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUserId;
      
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      final location = await locationProvider.getOrCreateLocation(
        latitude: _selectedLat!,
        longitude: _selectedLng!,
        customName: _addressController.text.isNotEmpty ? _addressController.text : null,
        customDescription: "Location for event: ${_titleController.text}",
      );

      setState(() {
        _isCreatingLocation = false;
      });

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      final event = EventInsertRequest(
        creatorUserId: currentUserId,
        locationId: location.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        eventTypeId: 1,
        maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 0,
        eventDate: _selectedDate,
        eventTime: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
        statusId: 2,
        equipmentProvided: _equipmentProvided,
        equipmentList: _requiredEquipmentController.text.trim(),
        meetingPoint: _meetingPointController.text.trim(),
      );
      
      await eventProvider.insertWithFiles(event, files: _selectedImages);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Event created successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print("Submit error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error creating event: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isCreatingLocation = false;
      });
    }
  }
}
