import 'package:ecochallenge_mobile/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Import your existing models and providers
import 'package:ecochallenge_mobile/models/request.dart';
import 'package:ecochallenge_mobile/models/location.dart';
import 'package:ecochallenge_mobile/providers/request_provider.dart';
import 'package:ecochallenge_mobile/providers/location_provider.dart';


class CleanupMapPage extends StatefulWidget {
  const CleanupMapPage({Key? key}) : super(key: key);

  @override
  State<CleanupMapPage> createState() => _CleanupMapPageState();
}

class _CleanupMapPageState extends State<CleanupMapPage> {
  final MapController _mapController = MapController();
  List<RequestResponse> _unresolvedRequests = [];
  Map<int, LocationResponse> _locations = {};
  bool _isLoading = true;
  String? _error;
  RequestResponse? _selectedRequest;

  @override
  void initState() {
    super.initState();
    _loadUnresolvedRequests();
  }

  Future<void> _loadUnresolvedRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);

      // Create search filter for unresolved requests
      final searchFilter = RequestSearchObject(
        retrieveAll: true,
      );

      // Fetch all requests
      final requestResult = await requestProvider.get(filter: searchFilter.toJson());
      final allRequests = requestResult.items ?? [];

      // Filter for unresolved requests (completedAt is null)
      final unresolvedRequests = allRequests.where((request) {
        return request.completedAt == null;
      }).toList();

      // Fetch location details for each request
      final locationIds = unresolvedRequests.map((r) => r.locationId).toSet();
      final Map<int, LocationResponse> locationMap = {};

      for (final locationId in locationIds) {
        try {
          final locationResult = await locationProvider.get();
          final location = locationResult.items?.firstWhere(
            (loc) => loc.id == locationId,
            orElse: () => throw Exception('Location not found'),
          );
          if (location != null) {
            locationMap[locationId] = location;
          }
        } catch (e) {
          print('Error fetching location $locationId: $e');
        }
      }

      setState(() {
        _unresolvedRequests = unresolvedRequests;
        _locations = locationMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Marker> _buildMarkers() {
    return _unresolvedRequests.map((request) {
      final location = _locations[request.locationId];
      if (location == null) return null;

      return Marker(
        point: LatLng(location.latitude, location.longitude),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedRequest = request;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMarkerColor(request.urgencyLevel),
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
            child: Icon(
              _getMarkerIcon(location.locationType),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  Color _getMarkerColor(UrgencyLevel urgencyLevel) {
    switch (urgencyLevel) {
      case UrgencyLevel.critical:
        return Colors.red;
      case UrgencyLevel.high:
        return Colors.orange;
      case UrgencyLevel.medium:
        return Colors.yellow[700]!;
      case UrgencyLevel.low:
        return Colors.green;
    }
  }

  IconData _getMarkerIcon(LocationType locationType) {
    switch (locationType) {
      case LocationType.park:
        return Icons.park;
      case LocationType.beach:
        return Icons.beach_access;
      case LocationType.forest:
        return Icons.forest;
      case LocationType.urban:
        return Icons.location_city;
      case LocationType.other:
        return Icons.place;
    }
  }

  Widget _buildInfoWindow() {
    if (_selectedRequest == null) return const SizedBox.shrink();

    final location = _locations[_selectedRequest!.locationId];
    if (location == null) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedRequest!.title ?? location.name ?? 'Cleanup Location',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedRequest = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedRequest!.description != null) ...[
                Text(
                  _selectedRequest!.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_selectedRequest!.photoUrls != null && _selectedRequest!.photoUrls!.isNotEmpty) ...[
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(_selectedRequest!.photoUrls!.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reported: ${DateFormat('MMM dd, yyyy').format(_selectedRequest!.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMarkerColor(_selectedRequest!.urgencyLevel).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedRequest!.urgencyLevel.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getMarkerColor(_selectedRequest!.urgencyLevel),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      location.locationType.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showParticipationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join Cleanup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParticipationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Cleanup'),
        content: const Text('Would you like to participate in this cleanup activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for joining the cleanup!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading cleanup locations',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUnresolvedRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_unresolvedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'No cleanup locations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All locations have been cleaned up!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _locations.isNotEmpty
            ? LatLng(
                _locations.values.first.latitude,
                _locations.values.first.longitude,
              )
            : const LatLng(51.5, -0.09), // Default to London
        initialZoom: 13.0,
        onTap: (tapPosition, point) {
          setState(() {
            _selectedRequest = null;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ecochallenge_mobile',
        ),
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Cleanup map',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFD4A574),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadUnresolvedRequests,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMapContent(),
          _buildInfoWindow(),
        ],
      ),
      bottomNavigationBar: const SharedBottomNavigation(
        currentIndex: 0, // Map is at index 0 (language/global icon)
      ),
    );
  }
}