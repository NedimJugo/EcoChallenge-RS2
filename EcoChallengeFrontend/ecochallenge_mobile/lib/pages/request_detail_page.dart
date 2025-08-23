import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../models/location.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import 'map_view_page.dart';
import 'package:ecochallenge_mobile/pages/proof_submission_page.dart';

class RequestDetailPage extends StatefulWidget {
  final RequestResponse request;

  const RequestDetailPage({Key? key, required this.request}) : super(key: key);

  @override
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  bool _isSigningUp = false;
  LocationResponse? _location;
  bool _isLoadingLocation = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      final result = await locationProvider.get();
      final locations = result.items ?? [];
      
      _location = locations.firstWhere(
        (loc) => loc.id == widget.request.locationId,
        orElse: () => LocationResponse(
          id: widget.request.locationId,
          name: 'Unknown Location',
          latitude: 0.0,
          longitude: 0.0,
          locationType: LocationType.other,
          createdAt: DateTime.now(),
        ),
      );
      
      setState(() => _isLoadingLocation = false);
    } catch (e) {
      debugPrint('Error loading location: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _openMapView() async {
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location not available'),
          backgroundColor: Colors.orange,
        ),
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

  Widget _buildImageCarousel() {
    final photoUrls = widget.request.photoUrls;
    final hasPhotos = photoUrls?.isNotEmpty == true;
    final imageCount = photoUrls?.length ?? 0;

    return Stack(
      children: [
        Container(
          height: 300,
          child: hasPhotos
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: imageCount,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) => _buildImageItem(photoUrls![index]),
                )
              : _buildNoImagesPlaceholder(),
        ),
        if (hasPhotos && imageCount > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageCount, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return Hero(
      tag: 'request-image-${widget.request.id}',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.3), Colors.transparent],
          ),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Color(0xFF4CAF50),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Image load error: $error');
            return _buildImageErrorPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildNoImagesPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cleaning_services, size: 80, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(
              'No images available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: goldenBrown,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequestInfo(),
                _buildLocationSection(),
                _buildDetailsSection(),
                _buildSignUpButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.request.title ?? 'Untitled Request',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
              height: 1.3,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Text(
              widget.request.description ?? 'No description available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 20),
              SizedBox(width: 8),
              Text(
                'Location Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_isLoadingLocation)
            Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          else if (_location != null) ...[
            _buildLocationCard(),
            SizedBox(height: 20),
            _buildTerrainMap(),
          ]
          else
            Text(
              'Location information not available',
              style: TextStyle(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _location!.name ?? 'Unknown Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            if (_location!.address != null)
              _buildLocationDetail(Icons.place, _location!.address!),
            if (_location!.city != null)
              _buildLocationDetail(Icons.location_city, _location!.city!),
            SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  backgroundColor: _getLocationTypeColor(_location!.locationType),
                  label: Text(
                    _location!.locationType.displayName,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Spacer(),
                if (_location!.latitude != 0.0 && _location!.longitude != 0.0)
                  Text(
                    '${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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

  Widget _buildTerrainMap() {
    final hasValidCoordinates = _location != null && 
        _location!.latitude != 0.0 && 
        _location!.longitude != 0.0;

    return GestureDetector(
      onTap: _openMapView,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Modern gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green[100]!,
                      Colors.blue[100]!,
                      Colors.brown[100]!,
                    ],
                  ),
                ),
              ),
              // Terrain pattern
              CustomPaint(
                size: Size(double.infinity, 140),
                painter: TerrainPainter(),
              ),
              if (hasValidCoordinates)
                Positioned(
                  left: 60,
                  top: 50,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              // Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _location!.name ?? 'Unknown Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasValidCoordinates)
                      Text(
                        '${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'View Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!hasValidCoordinates)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off, size: 32, color: Colors.white70),
                        SizedBox(height: 8),
                        Text(
                          'Coordinates not available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF4CAF50), size: 20),
              SizedBox(width: 8),
              Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ..._buildDetailItems(),
        ],
      ),
    );
  }

  List<Widget> _buildDetailItems() {
    final items = <Widget>[];
    
    if (widget.request.proposedDate != null) {
      items.add(_buildDetailCard(
        Icons.calendar_today,
        'Proposed Date',
        _formatDate(widget.request.proposedDate!),
      ));
    }
    
    if (widget.request.proposedTime != null) {
      items.add(_buildDetailCard(
        Icons.access_time,
        'Proposed Time',
        widget.request.proposedTime!,
      ));
    }
    
    items.addAll([
      _buildDetailCard(
        Icons.warning,
        'Urgency Level',
        widget.request.urgencyLevel.displayName,
      ),
      _buildDetailCard(
        Icons.clean_hands,
        'Estimated Amount',
        widget.request.estimatedAmount.displayName,
      ),
      if (widget.request.estimatedCleanupTime != null)
        _buildDetailCard(
          Icons.timer,
          'Estimated Time',
          '${widget.request.estimatedCleanupTime} minutes',
        ),
      _buildDetailCard(
        Icons.star,
        'Reward Points',
        '${widget.request.suggestedRewardPoints}',
      ),
      if (widget.request.suggestedRewardMoney > 0)
        _buildDetailCard(
          Icons.attach_money,
          'Money Reward',
          '\$${widget.request.suggestedRewardMoney.toStringAsFixed(2)}',
        ),
    ]);

    return items;
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    final hasMoneyReward = widget.request.suggestedRewardMoney > 0;
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSigningUp ? null : _navigateToProofSubmission,
          style: ElevatedButton.styleFrom(
            backgroundColor: forestGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            padding: EdgeInsets.symmetric(horizontal: 24),
          ),
          child: _isSigningUp
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera, size: 20),
                    SizedBox(width: 12),
                    Text(
                      hasMoneyReward
                          ? 'Submit Proof & Get Reward'
                          : 'Submit Cleanup Proof',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
        return Color(0xFF4CAF50);
      case LocationType.beach:
        return Color(0xFF2196F3);
      case LocationType.forest:
        return Color(0xFF795548);
      case LocationType.urban:
        return Color(0xFF607D8B);
      case LocationType.other:
        return Color(0xFFFF9800);
    }
  }

  void _navigateToProofSubmission() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUserId;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to submit proof'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProofSubmissionPage(request: widget.request),
        settings: RouteSettings(name: '/proof-submission'),
      ),
    );
  }
}

class TerrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..color = Colors.brown.withOpacity(0.2);

    // Draw smooth contour lines
    _drawContourLine(canvas, size, 0.3, 0.2, 0.6, 0.4, 0.8, 0.5, paint);
    _drawContourLine(canvas, size, 0.6, 0.5, 0.7, 0.7, 0.9, 0.8, paint);
    _drawContourLine(canvas, size, 0.8, 0.7, 0.5, 0.9, 0.8, 0.95, paint);

    // Add subtle vegetation
    _drawVegetation(canvas, size);
  }

  void _drawContourLine(
    Canvas canvas,
    Size size,
    double startY,
    double cp1x,
    double cp1y,
    double cp2x,
    double cp2y,
    double endY,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(0, size.height * startY);
    path.cubicTo(
      size.width * cp1x,
      size.height * cp1y,
      size.width * cp2x,
      size.height * cp2y,
      size.width,
      size.height * endY,
    );
    canvas.drawPath(path, paint);
  }

  void _drawVegetation(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green.withOpacity(0.3);

    const spots = [
      Offset(0.2, 0.4),
      Offset(0.4, 0.6),
      Offset(0.7, 0.3),
      Offset(0.8, 0.7),
      Offset(0.3, 0.8),
      Offset(0.6, 0.5),
      Offset(0.9, 0.6),
    ];

    for (final spot in spots) {
      canvas.drawCircle(
        Offset(size.width * spot.dx, size.height * spot.dy),
        4 + spot.dx * 2, // Vary size for natural look
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}