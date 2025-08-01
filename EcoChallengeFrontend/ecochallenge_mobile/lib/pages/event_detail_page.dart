import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/event_participant.dart';
import '../providers/event_participant_provider.dart';
import '../providers/event_provider.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import 'map_view_page.dart';

class EventDetailPage extends StatefulWidget {
  final EventResponse event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isSigningUp = false;
  LocationResponse? _location;
  bool _isLoadingLocation = true;
  bool _eventExists = true;
  bool _isAlreadyRegistered = false;

  @override
  void initState() {
    super.initState();
    _verifyEventExists();
    _loadLocation();
    _checkExistingRegistration();
  }

  // Check if user is already registered for this event
  Future<void> _checkExistingRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUserId;
    
    if (userId == null || widget.event.id == null) return;
    
    try {
      final participantProvider = Provider.of<EventParticipantProvider>(context, listen: false);
      final participations = await participantProvider.getUserParticipations(userId);
      
      final isRegistered = participations.any((p) => p.eventId == widget.event.id);
      
      if (mounted) {
        setState(() => _isAlreadyRegistered = isRegistered);
      }
    } catch (e) {
      print('DEBUG: Error checking existing registration: $e');
    }
  }

  // Enhanced event verification
  Future<void> _verifyEventExists() async {
    try {
      if (widget.event.id == null || widget.event.title == null) {
        _showEventExpired();
        return;
      }

      // Verify the event still exists in the database
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      try {
        // Try to get the specific event by ID
        final eventSearchObject = EventSearchObject(
          retrieveAll: true,
          status: 1, // Active status
        );
        final result = await eventProvider.get(filter: eventSearchObject.toJson());
        final events = result.items ?? [];
        
        // Check if our event still exists
        final eventStillExists = events.any((e) => e.id == widget.event.id);
        
        if (!eventStillExists) {
          print('DEBUG: Event ${widget.event.id} no longer exists in database');
          setState(() => _eventExists = false);
          _showEventExpired();
        } else {
          print('DEBUG: Event ${widget.event.id} verified to exist');
        }
      } catch (e) {
        print('DEBUG: Error verifying event existence: $e');
        // If we can't verify, assume it exists to avoid blocking the user
      }
    } catch (e) {
      print('DEBUG: Error in _verifyEventExists: $e');
      _showEventExpired();
    }
  }

  void _showEventExpired() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Event Unavailable'),
          content: Text('This event no longer exists or has been cancelled. You will be returned to the events list.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to events list
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _loadLocation() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final result = await locationProvider.get();
      final locations = result.items ?? [];
      
      _location = locations.firstWhere(
        (loc) => loc.id == widget.event.locationId,
        orElse: () => LocationResponse(
          id: widget.event.locationId,
          name: 'Unknown Location',
          latitude: 0.0,
          longitude: 0.0,
          locationType: LocationType.other,
          createdAt: DateTime.now(),
        ),
      );
      
      setState(() => _isLoadingLocation = false);
    } catch (e) {
      print('Error loading location: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _openMapView() async {
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapViewPage(location: _location!),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Early return if event is invalid or doesn't exist
    if (widget.event.id == null || !_eventExists) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Event Unavailable'),
          backgroundColor: Color(0xFFD4A574),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'This event is no longer available',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'The event may have been cancelled or removed',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B4513),
                ),
                child: Text('Back to Events', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFFD4A574),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Event Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildEventInfo(),
            _buildLocationSection(),
            _buildDetailsSection(),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 250,
      child: widget.event.photoUrls?.isNotEmpty == true
          ? PageView.builder(
              itemCount: widget.event.photoUrls!.length,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  child: Image.network(
                    widget.event.photoUrls![index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event, size: 60, color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : Container(
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event, size: 80, color: Colors.grey[600]),
                    SizedBox(height: 8),
                    Text(
                      'No images available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEventInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.event.title ?? 'Untitled Event',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              // Add event ID for debugging
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ID: ${widget.event.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Details:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.event.description ?? 'No description available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          if (_isLoadingLocation)
            CircularProgressIndicator()
          else if (_location != null) ...[
            Text(
              _location!.name ?? 'Unknown Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            if (_location!.address != null) ...[
              SizedBox(height: 4),
              Text(
                _location!.address!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (_location!.city != null) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_city, size: 16, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    _location!.city!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLocationTypeColor(_location!.locationType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _location!.locationType.displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Spacer(),
                if (_location!.latitude != 0.0 && _location!.longitude != 0.0)
                  Text(
                    'Lat: ${_location!.latitude.toStringAsFixed(4)}, Lng: ${_location!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: 12),
          _buildTerrainMap(),
        ],
      ),
    );
  }

  Widget _buildTerrainMap() {
    if (_location == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            'Location not available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final hasValidCoordinates = _location!.latitude != 0.0 && _location!.longitude != 0.0;
    
    return GestureDetector(
      onTap: _openMapView,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.green[100]!,
                      Colors.green[200]!,
                      Colors.brown[100]!,
                      Colors.brown[200]!,
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
              CustomPaint(
                size: Size(double.infinity, 120),
                painter: TerrainPainter(),
              ),
              if (hasValidCoordinates)
                Positioned(
                  left: 60,
                  top: 40,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _location!.name ?? 'Unknown Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasValidCoordinates)
                        Text(
                          '${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B4513),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'View Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!hasValidCoordinates)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 32, color: Colors.grey[500]),
                      SizedBox(height: 4),
                      Text(
                        'Location coordinates\nnot available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailRow('Date:', _formatDate(widget.event.eventDate)),
          _buildDetailRow('Time:', widget.event.eventTime),
          _buildDetailRow('Duration:', '${widget.event.durationMinutes} minutes'),
          _buildDetailRow('Participants:', '${widget.event.currentParticipants}/${widget.event.maxParticipants}'),
          if (widget.event.equipmentProvided)
            _buildDetailRow('Equipment:', 'Provided'),
          if (widget.event.meetingPoint != null)
            _buildDetailRow('Meeting Point:', widget.event.meetingPoint!),
          _buildDetailRow('Award Points:', '100'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSigningUp || _isAlreadyRegistered ? null : _signUpForEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAlreadyRegistered ? Colors.grey : Color(0xFF8B4513),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: _isSigningUp
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  _isAlreadyRegistered ? 'Already Registered' : 'Join community event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getLocationTypeColor(LocationType type) {
    switch (type) {
      case LocationType.park:
        return Colors.green;
      case LocationType.beach:
        return Colors.blue;
      case LocationType.forest:
        return Colors.brown;
      case LocationType.urban:
        return Colors.grey;
      case LocationType.other:
        return Colors.orange;
    }
  }

  // ENHANCED: Better signup with comprehensive error handling
  Future<void> _signUpForEvent() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUserId;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to sign up for events')),
      );
      return;
    }

    setState(() => _isSigningUp = true);

    try {
      if (widget.event.id == null) {
        throw Exception('This event is no longer available');
      }

      print('DEBUG: Attempting to sign up for event ${widget.event.id} (${widget.event.title})');
      
      final participantProvider = Provider.of<EventParticipantProvider>(context, listen: false);
      
      final participantRequest = EventParticipantInsertRequest(
        eventId: widget.event.id!,
        userId: userId,
        status: AttendanceStatus.registered,
      );

      print('DEBUG: Sending participant request: ${participantRequest.toJson()}');
      
      final result = await participantProvider.addParticipant(participantRequest);
      
      print('DEBUG: Successfully created participant: ${result.toJson()}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully signed up for ${widget.event.title}!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Update the registration status
      setState(() => _isAlreadyRegistered = true);
      
    } catch (e) {
      print('DEBUG: Error signing up for event: $e');
      
      String errorMessage;
      
      if (e.toString().contains('event no longer exists') || 
          e.toString().contains('cancelled')) {
        errorMessage = 'This event no longer exists and has been removed.';
        // Show dialog and go back to events list
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Event Removed'),
            content: Text('This event has been cancelled or removed. You will be returned to the events list.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to events list
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      } else if (e.toString().contains('already registered') || 
                 e.toString().contains('duplicate')) {
        errorMessage = 'You are already signed up for this event';
        setState(() => _isAlreadyRegistered = true);
      } else if (e.toString().contains('Unauthorized')) {
        errorMessage = 'Please log in again to sign up for events';
      } else if (e.toString().contains('full') || 
                 e.toString().contains('capacity')) {
        errorMessage = 'This event is full and no longer accepting registrations';
      } else {
        errorMessage = 'Failed to sign up: Unable to register for this event';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningUp = false);
      }
    }
  }
}

// Custom painter for terrain-like appearance
class TerrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    paint.color = Colors.brown.withOpacity(0.3);
    
    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(size.width * 0.3, size.height * 0.2, size.width * 0.6, size.height * 0.4);
    path1.quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width, size.height * 0.3);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.7, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.9, size.height * 0.8, size.width, size.height * 0.6);
    canvas.drawPath(path2, paint);

    final path3 = Path();
    path3.moveTo(0, size.height * 0.8);
    path3.quadraticBezierTo(size.width * 0.2, size.height * 0.7, size.width * 0.5, size.height * 0.9);
    path3.quadraticBezierTo(size.width * 0.8, size.height * 0.95, size.width, size.height * 0.8);
    canvas.drawPath(path3, paint);

    paint.style = PaintingStyle.fill;
    paint.color = Colors.green.withOpacity(0.4);
    
    final spots = [
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.8),
    ];
    
    for (final spot in spots) {
      canvas.drawCircle(spot, 3, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
