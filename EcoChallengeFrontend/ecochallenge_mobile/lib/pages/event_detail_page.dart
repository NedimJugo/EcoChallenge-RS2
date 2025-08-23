import 'package:ecochallenge_mobile/layouts/constants.dart';
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

class _EventDetailPageState extends State<EventDetailPage>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isSigningUp = false;
  bool _isLoadingLocation = true;
  bool _eventExists = true;
  bool _isAlreadyRegistered = false;
  bool _isInitializing = true;
  LocationResponse? _location;
  
  // Animation controllers
  late AnimationController _animationController;
  final PageController _pageController = PageController();

  // Constants
  static const _primaryColor = Color(0xFFD4A574);
  static const _buttonColor = Color(0xFF8B4513);
  static const _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
    _initializeEventData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
  }

  Future<void> _initializeEventData() async {
    try {
      await Future.wait([
        _verifyEventExists(),
        _loadLocation(),
        _checkExistingRegistration(),
      ]);
    } catch (e) {
      debugPrint('Error initializing event data: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
        _animationController.forward();
      }
    }
  }

  Future<void> _checkExistingRegistration() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUserId;
    
    if (userId == null) return;
    
    try {
      final participantProvider = context.read<EventParticipantProvider>();
      final participations = await participantProvider.getUserParticipations(userId);
      
      final isRegistered = participations.any((p) => 
        p.eventId == widget.event.id && 
        p.status == AttendanceStatus.registered
      );
      
      if (mounted) {
        setState(() => _isAlreadyRegistered = isRegistered);
      }
    } catch (e) {
      debugPrint('Error checking existing registration: $e');
    }
  }

  Future<void> _verifyEventExists() async {
    try {
      final eventProvider = context.read<EventProvider>();
      final eventSearchObject = EventSearchObject(
        retrieveAll: true,
        status: 2,
      );
      
      final result = await eventProvider.get(filter: eventSearchObject.toJson());
      final events = result.items ?? [];
      
      final eventStillExists = events.any((e) => e.id == widget.event.id);
      
      if (mounted && !eventStillExists) {
        setState(() => _eventExists = false);
      }
    } catch (e) {
      debugPrint('Error verifying event existence: $e');
    }
  }

  Future<void> _loadLocation() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      final result = await locationProvider.get();
      final locations = result.items ?? [];
      
      final location = locations.where((loc) => loc.id == widget.event.locationId).firstOrNull;
      
      if (mounted) {
        setState(() {
          _location = location ?? _createFallbackLocation();
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading location: $e');
      if (mounted) {
        setState(() {
          _location = _createFallbackLocation();
          _isLoadingLocation = false;
        });
      }
    }
  }

  LocationResponse _createFallbackLocation() {
    return LocationResponse(
      id: widget.event.locationId,
      name: 'Location information unavailable',
      latitude: 0.0,
      longitude: 0.0,
      locationType: LocationType.other,
      createdAt: DateTime.now(),
    );
  }

  void _showEventExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Event Unavailable'),
        content: const Text('This event no longer exists or has been cancelled. You will be returned to the events list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapView() async {
    if (_location == null || (_location!.latitude == 0.0 && _location!.longitude == 0.0)) {
      _showSnackBar('Location coordinates not available', isError: true);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapViewPage(location: _location!),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScaffold();
    }

    if (!_eventExists) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showEventExpiredDialog());
      return _buildEventUnavailableScaffold();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                children: [
                  _buildEventInfo(),
                  _buildLocationSection(),
                  _buildDetailsSection(),
                  _buildSignUpButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: const Text('Loading...', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading event details...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventUnavailableScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Unavailable'),
        backgroundColor: _primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'This event is no longer available',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The event may have been cancelled or removed',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Events'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: goldenBrown,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        
        background: _buildImageCarousel(),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final photos = widget.event.photoUrls;
    
    if (photos?.isEmpty ?? true) {
      return _buildPlaceholderImage();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: photos!.length,
          itemBuilder: (context, index) => _buildNetworkImage(photos[index]),
        ),
        if (photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 60, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'No images available',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.event.title ?? 'Untitled Event',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDescriptionSection(),
          ],
        ),
      ),
    );
  }



  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.event.description ?? 'No description available',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingLocation)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildLocationInfo(),
              const SizedBox(height: 16),
              _buildTerrainMap(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    if (_location == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _location!.name ?? 'Unknown Location',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        if (_location!.address?.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(
            _location!.address!,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
        if (_location!.city?.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_city, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                _location!.city!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLocationTypeBadge(_location!.locationType),
            const Spacer(),
            if (_hasValidCoordinates())
              Text(
                'Lat: ${_location!.latitude.toStringAsFixed(4)}, Lng: ${_location!.longitude.toStringAsFixed(4)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationTypeBadge(LocationType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getLocationTypeColor(type),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _hasValidCoordinates() {
    return _location != null && 
           _location!.latitude != 0.0 && 
           _location!.longitude != 0.0;
  }

  Widget _buildTerrainMap() {
    if (_location == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _openMapView,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              _buildTerrainBackground(),
              _buildLocationMarker(),
              _buildMapButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerrainBackground() {
    return Container(
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
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 120),
        painter: TerrainPainter(),
      ),
    );
  }

  Widget _buildLocationMarker() {
    if (!_hasValidCoordinates()) return const SizedBox.shrink();

    return Positioned(
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildMapButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openMapView,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: forestGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
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
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildDetailRows(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRows() {
    return Column(
      children: [
        _buildDetailRow('Date', _formatDate(widget.event.eventDate)),
        _buildDetailRow('Time', widget.event.eventTime),
        _buildDetailRow('Duration', '${widget.event.durationMinutes} minutes'),
        _buildDetailRow('Participants', '${widget.event.currentParticipants}/${widget.event.maxParticipants}'),
        if (widget.event.equipmentProvided)
          _buildDetailRow('Equipment', 'Provided'),
        if (widget.event.meetingPoint?.isNotEmpty ?? false)
          _buildDetailRow('Meeting Point', widget.event.meetingPoint!),
        _buildDetailRow('Award Points', '100'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _getButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: _isSigningUp ? 0 : 2,
            ),
            child: _buildButtonChild(),
          ),
        ),
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    if (_isSigningUp || _isAlreadyRegistered) return null;
    return _signUpForEvent;
  }

  Color _getButtonColor() {
    if (_isAlreadyRegistered) return Colors.grey;
    if (_isSigningUp) return Colors.grey[400]!;
    return forestGreen;
  }

  Widget _buildButtonChild() {
    if (_isSigningUp) {
      return const CircularProgressIndicator(color: Colors.white, strokeWidth: 2);
    }
    
    return Text(
      _isAlreadyRegistered ? 'Already Registered' : 'Join Community Event',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUserId;
    
    if (userId == null) {
      _showSnackBar('Please log in to sign up for events', isError: true);
      return;
    }

    setState(() => _isSigningUp = true);

    try {
      debugPrint('Attempting to sign up for event ${widget.event.id} (${widget.event.title})');
      
      final participantProvider = context.read<EventParticipantProvider>();
      final participantRequest = EventParticipantInsertRequest(
        eventId: widget.event.id,
        userId: userId,
        status: AttendanceStatus.registered,
      );

      debugPrint('Sending participant request: ${participantRequest.toJson()}');
      
      final result = await participantProvider.addParticipant(participantRequest);
      debugPrint('Successfully created participant: ${result.toJson()}');
      
      _showSnackBar('Successfully signed up for ${widget.event.title}!');
      setState(() => _isAlreadyRegistered = true);
      
      HapticFeedback.lightImpact();
      
    } catch (e) {
      debugPrint('Error signing up for event: $e');
      _handleSignUpError(e);
    } finally {
      if (mounted) {
        setState(() => _isSigningUp = false);
      }
    }
  }

  void _handleSignUpError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('event no longer exists') || 
        errorString.contains('cancelled')) {
      _showEventRemovedDialog();
    } else if (errorString.contains('already registered') || 
               errorString.contains('duplicate')) {
      _showSnackBar('You are already signed up for this event', isError: true);
      setState(() => _isAlreadyRegistered = true);
    } else if (errorString.contains('unauthorized')) {
      _showSnackBar('Please log in again to sign up for events', isError: true);
    } else if (errorString.contains('full') || 
               errorString.contains('capacity')) {
      _showSnackBar('This event is full and no longer accepting registrations', isError: true);
    } else {
      _showSnackBar('Failed to sign up: Unable to register for this event', isError: true);
    }
  }

  void _showEventRemovedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event Removed'),
        content: const Text('This event has been cancelled or removed. You will be returned to the events list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)..pop()..pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class TerrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = Colors.brown.withOpacity(0.3);

    final paths = [
      _createTerrainPath(size, 0.3, 0.2, 0.4, 0.5, 0.3),
      _createTerrainPath(size, 0.6, 0.5, 0.7, 0.8, 0.6),
      _createTerrainPath(size, 0.8, 0.7, 0.9, 0.95, 0.8),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    paint
      ..style = PaintingStyle.fill
      ..color = Colors.green.withOpacity(0.4);

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

  Path _createTerrainPath(Size size, double startY, double midY1, double midY2, double endY1, double endY2) {
    final path = Path();
    path.moveTo(0, size.height * startY);
    path.quadraticBezierTo(
      size.width * 0.3, 
      size.height * midY1, 
      size.width * 0.6, 
      size.height * midY2
    );
    path.quadraticBezierTo(
      size.width * 0.8, 
      size.height * endY1, 
      size.width, 
      size.height * endY2
    );
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}