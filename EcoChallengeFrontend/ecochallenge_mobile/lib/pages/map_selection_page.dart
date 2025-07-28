import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/osm_map_widget.dart';
import '../widgets/simple_map_fallback.dart';

class MapSelectionPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  
  const MapSelectionPage({
    Key? key,
    this.initialLat,
    this.initialLng,
  }) : super(key: key);
  
  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  double? _selectedLat;
  double? _selectedLng;
  String _selectedAddress = '';
  bool _isLoadingAddress = false;
  bool _isLoadingLocation = false;
  bool _useMapFallback = false;
  
  @override
  void initState() {
    super.initState();
    _selectedLat = widget.initialLat ?? 45.521563; // Default to Portland
    _selectedLng = widget.initialLng ?? -122.677433;
    if (_selectedLat != null && _selectedLng != null) {
      _getAddressFromCoordinates(_selectedLat!, _selectedLng!);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Color(0xFF2D5016),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          if (_selectedLat != null && _selectedLng != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'lat': _selectedLat,
                  'lng': _selectedLng,
                  'address': _selectedAddress,
                });
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tap on the map to select a location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isLoadingLocation)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                if (_selectedAddress.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Selected: $_selectedAddress',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      if (_isLoadingAddress)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ],
                if (_selectedLat != null && _selectedLng != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'Coordinates: ${_selectedLat!.toStringAsFixed(6)}, ${_selectedLng!.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _selectedLat != null && _selectedLng != null
                ? _buildMapWidget()
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapWidget() {
    try {
      if (_useMapFallback) {
        return SimpleMapFallback(
          latitude: _selectedLat!,
          longitude: _selectedLng!,
          zoom: 15.0,
          onLocationSelected: (lat, lng) {
            setState(() {
              _selectedLat = lat;
              _selectedLng = lng;
            });
            _getAddressFromCoordinates(lat, lng);
          },
        );
      } else {
        return OSMMapWidget(
          latitude: _selectedLat!,
          longitude: _selectedLng!,
          zoom: 15.0,
          onLocationSelected: (lat, lng) {
            setState(() {
              _selectedLat = lat;
              _selectedLng = lng;
            });
            _getAddressFromCoordinates(lat, lng);
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
        zoom: 15.0,
        onLocationSelected: (lat, lng) {
          setState(() {
            _selectedLat = lat;
            _selectedLng = lng;
          });
          _getAddressFromCoordinates(lat, lng);
        },
      );
    }
  }
  
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog();
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
      });
      
      _getAddressFromCoordinates(position.latitude, position.longitude);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }
  
  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    setState(() {
      _isLoadingAddress = true;
    });
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Address not found';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }
  
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Denied'),
        content: Text('Location permission is required to get your current location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Permanently Denied'),
        content: Text('Please enable location permission in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }
}