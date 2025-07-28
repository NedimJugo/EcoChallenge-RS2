import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OSMMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool isInteractive;
  final Function(double lat, double lng)? onLocationSelected;
  final double zoom;
  
  const OSMMapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.isInteractive = true,
    this.onLocationSelected,
    this.zoom = 15.0,
  }) : super(key: key);
  
  @override
  _OSMMapWidgetState createState() => _OSMMapWidgetState();
}

class _OSMMapWidgetState extends State<OSMMapWidget> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = LatLng(widget.latitude, widget.longitude);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.latitude, widget.longitude),
            initialZoom: widget.zoom,
            interactionOptions: InteractionOptions(
              flags: widget.isInteractive 
                  ? InteractiveFlag.all 
                  : InteractiveFlag.none,
            ),
            onTap: widget.isInteractive ? (tapPosition, point) {
              setState(() {
                _selectedLocation = point;
              });
              if (widget.onLocationSelected != null) {
                widget.onLocationSelected!(point.latitude, point.longitude);
              }
            } : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ecochallenge_mobile',
              maxZoom: 19,
            ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}