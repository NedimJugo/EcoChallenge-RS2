import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/event_participant.dart';
import '../providers/event_participant_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLocation();
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFFD4A574),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
          Text(
            widget.event.title ?? 'Untitled Event',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
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
              // Terrain-like background
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
              // Terrain pattern
              CustomPaint(
                size: Size(double.infinity, 120),
                painter: TerrainPainter(),
              ),
              // Location marker
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
              // Location info overlay
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
              // View map button
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
              // No coordinates overlay
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
          onPressed: _isSigningUp ? null : _signUpForEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8B4513),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: _isSigningUp
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Join community event',
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
      final participantProvider = Provider.of<EventParticipantProvider>(context, listen: false);
      
      final participantRequest = EventParticipantInsertRequest(
        eventId: widget.event.id,
        userId: userId,
        status: AttendanceStatus.Registered,
      );

      await participantProvider.insert(participantRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully signed up for ${widget.event.title}!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing up: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSigningUp = false);
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

    // Draw terrain contour lines
    paint.color = Colors.brown.withOpacity(0.3);
    
    // Draw some curved contour lines to simulate terrain
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

    // Add some vegetation dots
    paint.style = PaintingStyle.fill;
    paint.color = Colors.green.withOpacity(0.4);
    
    // Random vegetation spots
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
