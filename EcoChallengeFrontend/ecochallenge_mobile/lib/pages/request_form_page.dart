import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/request.dart';
import '../providers/request_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/custom_background.dart';
import '../widgets/osm_map_widget.dart';
import '../widgets/simple_map_fallback.dart';
import 'map_selection_page.dart';

class RequestFormPage extends StatefulWidget {
  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _useMapFallback = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String? _titleError;
  String? _descriptionError;
  String? _addressError;
  String? _locationError;

  // Form data
  UrgencyLevel _selectedUrgency = UrgencyLevel.low;
  EstimatedAmount _selectedAmount = EstimatedAmount.small;
  int _estimatedTime = 30;
  List<File> _selectedImages = [];
  double? _selectedLat;
  double? _selectedLng;
  bool _isCreatingLocation = false;

  bool _validateCurrentPage() {
    setState(() {
      _titleError = null;
      _descriptionError = null;
      _addressError = null;
      _locationError = null;
    });

    bool isValid = true;

    if (_currentPage == 0) {
      if (_titleController.text.trim().isEmpty) {
        _titleError = 'Title is required';
        isValid = false;
      } else if (_titleController.text.trim().length < 3) {
        _titleError = 'Title must be at least 3 characters';
        isValid = false;
      } else if (_titleController.text.trim().length > 100) {
        _titleError = 'Title must be less than 100 characters';
        isValid = false;
      }

      if (_descriptionController.text.trim().isEmpty) {
        _descriptionError = 'Description is required';
        isValid = false;
      } else if (_descriptionController.text.trim().length < 10) {
        _descriptionError = 'Description must be at least 10 characters';
        isValid = false;
      } else if (_descriptionController.text.trim().length > 500) {
        _descriptionError = 'Description must be less than 500 characters';
        isValid = false;
      }
    } else if (_currentPage == 1) {
      if (_addressController.text.trim().isEmpty) {
        _addressError = 'Address is required';
        isValid = false;
      }
      if (_selectedLat == null || _selectedLng == null) {
        _locationError = 'Please select a location on the map';
        isValid = false;
      }
    }

    setState(() {});
    return isValid;
  }

  void _nextPage() {
    if (_validateCurrentPage()) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
                  gradient: LinearGradient(
                    colors: [Color(0xFF2D5016), Color(0xFF4A7C59)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                            _getPageTitle(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.3),
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
                    _buildRequestInfoPage(),
                    _buildLocationPage(),
                    _buildDetailsPage(),
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

  String _getPageTitle() {
    switch (_currentPage) {
      case 0: return 'Request Info';
      case 1: return 'Location';
      case 2: return 'Details';
      case 3: return 'Photos';
      case 4: return 'Review';
      default: return 'Request Form';
    }
  }


  Widget _buildRequestInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cleaning_services,
                  size: 48,
                  color: Color(0xFF2D5016),
                ),
                SizedBox(height: 12),
                Text(
                  'Every good cleanup\nhas a name!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5016),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'What\'s the scoop? Be as detailed as your grandma\'s stew recipe.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          Text(
            'Title *',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.title, color: Color(0xFF2D5016)),
                hintText: 'Enter cleanup title...',
                errorText: _titleError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2D5016), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_titleError != null) {
                  setState(() {
                    _titleError = null;
                  });
                }
              },
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Description *',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description, color: Color(0xFF2D5016)),
                ),
                hintText: 'Describe the cleanup area and what needs to be done...',
                errorText: _descriptionError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2D5016), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_descriptionError != null) {
                  setState(() {
                    _descriptionError = null;
                  });
                }
              },
            ),
          ),
          
          Spacer(),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2D5016).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade700, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pin the exact location for cleanup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Address *',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5016),
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.location_city, color: Color(0xFF2D5016)),
                hintText: 'Enter address or location name...',
                errorText: _addressError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2D5016), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_addressError != null) {
                  setState(() {
                    _addressError = null;
                  });
                }
              },
            ),
          ),
          
          SizedBox(height: 20),
          
          Row(
            children: [
              Text(
                'Map Location *',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5016),
                ),
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton.icon(
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
                        _locationError = null;
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Color(0xFF2D5016)),
                    ),
                  ),
                  icon: Icon(Icons.fullscreen, color: Color(0xFF2D5016)),
                  label: Text(
                    'Full Screen',
                    style: TextStyle(color: Color(0xFF2D5016), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _locationError != null ? Colors.red : Colors.grey.shade300,
                width: _locationError != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMapWidget(),
            ),
          ),
          
          if (_locationError != null)
            Padding(
              padding: EdgeInsets.only(top: 8, left: 12),
              child: Text(
                _locationError!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          
          Spacer(),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2D5016).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
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
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Tap "Full Screen" to select location',
                style: TextStyle(color: Colors.grey.shade600),
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

  Widget _buildDetailsPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.orange.shade700, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Help us understand the cleanup requirements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          _buildEnhancedDropdown(
            'Urgency Level',
            Icons.priority_high,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButton<UrgencyLevel>(
                value: _selectedUrgency,
                isExpanded: true,
                underline: SizedBox(),
                items: [
                  DropdownMenuItem(value: UrgencyLevel.low, child: Text('🟢 Low')),
                  DropdownMenuItem(value: UrgencyLevel.medium, child: Text('🟡 Medium')),
                  DropdownMenuItem(value: UrgencyLevel.high, child: Text('🟠 High')),
                  DropdownMenuItem(value: UrgencyLevel.critical, child: Text('🔴 Critical')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUrgency = value ?? UrgencyLevel.low;
                  });
                },
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          _buildEnhancedDropdown(
            'Estimated Amount',
            Icons.delete_outline,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButton<EstimatedAmount>(
                value: _selectedAmount,
                isExpanded: true,
                underline: SizedBox(),
                items: [
                  DropdownMenuItem(value: EstimatedAmount.small, child: Text('🗑️ Small (1-5 bags)')),
                  DropdownMenuItem(value: EstimatedAmount.medium, child: Text('🗑️🗑️ Medium (6-15 bags)')),
                  DropdownMenuItem(value: EstimatedAmount.large, child: Text('🗑️🗑️🗑️ Large (16+ bags)')),
                  DropdownMenuItem(value: EstimatedAmount.huge, child: Text('🗑️🗑️🗑️🗑️ Huge (30+ bags)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAmount = value ?? EstimatedAmount.small;
                  });
                },
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          _buildEnhancedDropdown(
            'Estimated Time',
            Icons.access_time,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButton<int>(
                value: _estimatedTime,
                isExpanded: true,
                underline: SizedBox(),
                items: [
                  DropdownMenuItem(value: 15, child: Text('⏱️ 15 minutes')),
                  DropdownMenuItem(value: 30, child: Text('⏱️ 30 minutes')),
                  DropdownMenuItem(value: 60, child: Text('⏱️ 1 hour')),
                  DropdownMenuItem(value: 120, child: Text('⏱️ 2 hours')),
                  DropdownMenuItem(value: 240, child: Text('⏱️ 4+ hours')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estimatedTime = value ?? 30;
                  });
                },
              ),
            ),
          ),
          
          Spacer(),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2D5016).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDropdown(String label, IconData icon, Widget dropdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF2D5016), size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5016),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        dropdown,
      ],
    );
  }

  Widget _buildPhotosPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.purple.shade700, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Show us the cleanup area',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      Text(
                        'Photos help volunteers understand the task better',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                  width: 2,
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
                              color: Colors.grey.shade100,
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
                            'Add Photos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5016),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to capture or select photos\nfrom your gallery',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(12),
                      child: GridView.builder(
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
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF2D5016),
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Color(0xFF2D5016),
                                      size: 32,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add More',
                                      style: TextStyle(
                                        color: Color(0xFF2D5016),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
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
                                          offset: Offset(0, 2),
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
          ),
          
          SizedBox(height: 12),
          Text(
            '${_selectedImages.length} photo${_selectedImages.length != 1 ? 's' : ''} selected',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          Spacer(),
          
          Center(
            child: Container(
              width: 160,
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2D5016).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Review your cleanup request',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEnhancedReviewItem('Title', _titleController.text, Icons.title),
                    _buildEnhancedReviewItem('Description', _descriptionController.text, Icons.description),
                    _buildEnhancedReviewItem('Address', _addressController.text, Icons.location_city),
                    _buildEnhancedReviewItem('Urgency', _getUrgencyText(_selectedUrgency), Icons.priority_high),
                    _buildEnhancedReviewItem('Amount', _getAmountText(_selectedAmount), Icons.delete_outline),
                    _buildEnhancedReviewItem('Estimated Time', '$_estimatedTime minutes', Icons.access_time),
                    _buildEnhancedReviewItem('Photos', '${_selectedImages.length} selected', Icons.camera_alt),
                    
                    if (_selectedLat != null && _selectedLng != null) ...[
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.map, color: Color(0xFF2D5016), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Location Preview:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2D5016),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildMapWidget(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2D5016).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isCreatingLocation ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D5016),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
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
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Creating Location...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildEnhancedReviewItem(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF2D5016), size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2D5016),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not specified' : value,
                  style: TextStyle(
                    color: value.isEmpty ? Colors.grey : Colors.black87,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUrgencyText(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low: return 'Low';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.high: return 'High';
      case UrgencyLevel.critical: return 'Critical';
    }
  }

  String _getAmountText(EstimatedAmount amount) {
    switch (amount) {
      case EstimatedAmount.small: return 'Small (1-5 bags)';
      case EstimatedAmount.medium: return 'Medium (6-15 bags)';
      case EstimatedAmount.large: return 'Large (16+ bags)';
      case EstimatedAmount.huge: return 'Huge (30+ bags)';
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _selectedImages.add(File(image.path));
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final List<XFile>? images = await picker.pickMultiImage();
                if (images != null) {
                  setState(() {
                    _selectedImages.addAll(images.map((image) => File(image.path)));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a description');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter an address');
      return;
    }

    if (_selectedLat == null || _selectedLng == null) {
      _showErrorSnackBar('Please select a location on the map');
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
        customDescription: "Location for request: ${_titleController.text}",
      );

      setState(() {
        _isCreatingLocation = false;
      });

      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      
      final request = RequestInsertRequest(
        userId: currentUserId,
        locationId: location.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        urgencyLevel: _selectedUrgency,
        wasteTypeId: 1,
        estimatedAmount: _selectedAmount,
        statusId: 1,
        suggestedRewardPoints: 100,
        suggestedRewardMoney: 10.0,
        estimatedCleanupTime: _estimatedTime,
      );
      
      await requestProvider.insertWithFiles(request, files: _selectedImages);
      
      _showSuccessSnackBar('Request submitted successfully!');
      Navigator.pop(context);
    } catch (e) {
      print("Submit error: $e");
      _showErrorSnackBar('Error submitting request: $e');
    } finally {
      setState(() {
        _isCreatingLocation = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}
