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

  // Form data
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<File> _selectedImages = [];
  double? _selectedLat;
  double? _selectedLng;
  bool _equipmentProvided = false;
  bool _isCreatingLocation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
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
              
              // Bottom navigation
              Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.language, color: Colors.black54),
                    Icon(Icons.image, color: Colors.black54),
                    Icon(Icons.home, color: Colors.black54),
                    Icon(Icons.calendar_today, color: Colors.black54),
                    Icon(Icons.chat_bubble_outline, color: Colors.black54),
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Every good party\nhas a name!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'What\'s the scoop? Be as detailed as your grandma\'s stew recipe.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Title:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Description:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          Spacer(),
          
          Center(
            child: Container(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
          Text(
            'Event Location',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          
          Text(
            'Address:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Meeting Point:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _meetingPointController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: 'e.g., Main entrance, parking lot, etc.',
            ),
          ),
          
          SizedBox(height: 20),
          
          Row(
            children: [
              Text(
                'Map:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              TextButton.icon(
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
                    });
                  }
                },
                icon: Icon(Icons.fullscreen, color: Color(0xFF2D5016)),
                label: Text(
                  'Full Screen',
                  style: TextStyle(color: Color(0xFF2D5016)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          
          Container(
            height: 150,
            child: _buildMapWidget(),
          ),
          
          Spacer(),
          
          Center(
            child: Container(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildEventDetailsPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          
          Text(
            'Start date:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  Spacer(),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Start time:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Text('${_selectedTime.format(context)}'),
                  Spacer(),
                  Icon(Icons.access_time),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Max. participants:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _maxParticipantsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Row(
            children: [
              Checkbox(
                value: _equipmentProvided,
                onChanged: (value) {
                  setState(() {
                    _equipmentProvided = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'Equipment will be provided',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Equipment details:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _requiredEquipmentController,
            maxLines: 2,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: 'List equipment provided or needed...',
            ),
          ),
          
          Spacer(),
          
          Center(
            child: Container(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Photos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          
          Text(
            'Add photos to showcase your event:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _selectedImages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add photos',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          // Add more button
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.grey.shade600,
                                size: 30,
                              ),
                            ),
                          );
                        }
                        
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
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
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
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
          
          Spacer(),
          
          Center(
            child: Container(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
          Text(
            'Review Your Event',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewItem('Title', _titleController.text),
                    _buildReviewItem('Description', _descriptionController.text),
                    _buildReviewItem('Address', _addressController.text),
                    _buildReviewItem('Meeting Point', _meetingPointController.text),
                    _buildReviewItem('Date', '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    _buildReviewItem('Time', _selectedTime.format(context)),
                    _buildReviewItem('Max Participants', _maxParticipantsController.text),
                    _buildReviewItem('Equipment Provided', _equipmentProvided ? 'Yes' : 'No'),
                    _buildReviewItem('Equipment Details', _requiredEquipmentController.text),
                    _buildReviewItem('Photos', '${_selectedImages.length} selected'),
                    
                    if (_selectedLat != null && _selectedLng != null) ...[
                      SizedBox(height: 16),
                      Text(
                        'Location Preview:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 150,
                        child: _buildMapWidget(),
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
            height: 50,
            child: ElevatedButton(
              onPressed: _isCreatingLocation ? null : _submitEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D5016),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isCreatingLocation
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
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
                  : Text(
                      'Submit Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black,
              ),
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
  );
  if (picked != null) {
    setState(() {
      _selectedDate = picked;
    });
  }
}

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
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

  Future<void> _submitEvent() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isCreatingLocation = true;
      });

      // Get current user ID
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUserId;
      
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Create or get location
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

      // Now create the event
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      final event = EventInsertRequest(
        creatorUserId: currentUserId, // Use actual user ID
        locationId: location.id, // Use the created/found location ID
        title: _titleController.text,
        description: _descriptionController.text,
        eventTypeId: 1, // You might want to make this selectable
        maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 0,
        eventDate: _selectedDate,
        eventTime: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
        statusId: 1,
        equipmentProvided: _equipmentProvided,
        equipmentList: _requiredEquipmentController.text,
        meetingPoint: _meetingPointController.text,
      );
      
      // Use the method that handles multipart/form-data with files
      await eventProvider.insertWithFiles(event, files: _selectedImages);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print("Submit error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCreatingLocation = false;
      });
    }
  }
}