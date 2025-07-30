  import 'dart:math' as math;
  import 'package:geocoding/geocoding.dart';
  import 'package:ecochallenge_mobile/models/location.dart';
  import 'package:ecochallenge_mobile/providers/base_provider.dart';

  class LocationProvider extends BaseProvider<LocationResponse> {
    LocationProvider() : super("Location");

    @override
    LocationResponse fromJson(data) {
      return LocationResponse.fromJson(data);
    }

    // Add method to get all locations for dropdown usage
    Future<List<LocationResponse>> getAllLocations() async {
      try {
        final result = await get();
        return result.items ?? [];
      } catch (e) {
        throw Exception("Failed to get locations: $e");
      }
    }

    // Method to find existing location by coordinates (within a small radius)
    Future<LocationResponse?> findLocationByCoordinates(double latitude, double longitude, {double radiusKm = 0.1}) async {
      try {
        final result = await get();
        final items = result.items;
        
        if (items == null) return null;
        
        for (var location in items) {
          double distance = _calculateDistance(
            latitude, longitude, 
            location.latitude, location.longitude
          );
          
          if (distance <= radiusKm) {
            return location;
          }
        }
        
        return null;
      } catch (e) {
        print("Error finding location: $e");
        return null;
      }
    }

    // Method to create location with geocoding
    Future<LocationResponse> createLocationFromCoordinates({
      required double latitude,
      required double longitude,
      String? customName,
      String? customDescription,
      LocationType? customType,
    }) async {
      try {
        // Get address information from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

        // Determine location type based on address or use custom
        LocationType locationType = customType ?? _determineLocationType(place);

        // Create location name
        String locationName = customName ?? _generateLocationName(place, latitude, longitude);

        // Create the location request
        final locationRequest = LocationInsertRequest(
          name: locationName,
          description: customDescription ?? _generateDescription(place),
          latitude: latitude,
          longitude: longitude,
          address: _formatAddress(place),
          city: place?.locality ?? place?.subAdministrativeArea,
          country: place?.country,
          postalCode: place?.postalCode,
          locationType: locationType,
        );

        // Use regular insert method (JSON) instead of insertWithFiles for locations
        return await insert(locationRequest);
      } catch (e) {
        print("Error creating location: $e");
        // Fallback: create basic location without geocoding
        final basicLocationRequest = LocationInsertRequest(
          name: customName ?? "Location ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}",
          description: customDescription ?? "User selected location",
          latitude: latitude,
          longitude: longitude,
          locationType: customType ?? LocationType.other,
        );
        
        // Use regular insert method (JSON) for fallback as well
        return await insert(basicLocationRequest);
      }
    }

    // Method to get or create location from coordinates
    Future<LocationResponse> getOrCreateLocation({
      required double latitude,
      required double longitude,
      String? customName,
      String? customDescription,
      LocationType? customType,
    }) async {
      try {
        // First, try to find existing location nearby
        LocationResponse? existingLocation = await findLocationByCoordinates(
          latitude, 
          longitude,
          radiusKm: 0.1, // 100 meters radius
        );
        
        if (existingLocation != null) {
          print("Found existing location: ${existingLocation.name}");
          return existingLocation;
        }
        
        // If no existing location found, create a new one
        print("Creating new location at $latitude, $longitude");
        return await createLocationFromCoordinates(
          latitude: latitude,
          longitude: longitude,
          customName: customName,
          customDescription: customDescription,
          customType: customType,
        );
        
      } catch (e) {
        print("Error in getOrCreateLocation: $e");
        rethrow;
      }
    }

    // Helper method to determine location type from placemark
    LocationType _determineLocationType(Placemark? place) {
      if (place == null) return LocationType.other;
      
      String fullAddress = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
      ].where((element) => element != null && element.isNotEmpty).join(' ').toLowerCase();

      if (fullAddress.contains('park') || fullAddress.contains('garden')) {
        return LocationType.park;
      } else if (fullAddress.contains('beach') || fullAddress.contains('coast')) {
        return LocationType.beach;
      } else if (fullAddress.contains('forest') || fullAddress.contains('wood') || fullAddress.contains('trail')) {
        return LocationType.forest;
      } else if (place.locality != null && place.locality!.isNotEmpty) {
        return LocationType.urban;
      }
      
      return LocationType.other;
    }

    // Helper method to generate location name
    String _generateLocationName(Placemark? place, double lat, double lng) {
      if (place?.name != null && place!.name!.isNotEmpty) {
        return place.name!;
      } else if (place?.street != null && place!.street!.isNotEmpty) {
        return place.street!;
      } else if (place?.locality != null && place!.locality!.isNotEmpty) {
        return "${place.locality} Area";
      } else {
        return "Location ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
      }
    }

    // Helper method to generate description
    String _generateDescription(Placemark? place) {
      if (place == null) return "User selected location";
      
      List<String> parts = [
        place.subLocality,
        place.locality,
        place.administrativeArea,
      ].where((element) => element != null && element.isNotEmpty).cast<String>().toList();
      
      return parts.isNotEmpty ? "Located in ${parts.join(', ')}" : "User selected location";
    }

    // Helper method to format address
    String? _formatAddress(Placemark? place) {
      if (place == null) return null;
      
      List<String> addressParts = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((element) => element != null && element.isNotEmpty).cast<String>().toList();
      
      return addressParts.isNotEmpty ? addressParts.join(', ') : null;
    }

    // Helper method to calculate distance between two coordinates
    double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
      const double earthRadius = 6371; // Earth's radius in kilometers
      
      double dLat = _degreesToRadians(lat2 - lat1);
      double dLon = _degreesToRadians(lon2 - lon1);
      
      double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
      
      double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      
      return earthRadius * c;
    }

    double _degreesToRadians(double degrees) {
      return degrees * (math.pi / 180);
    }
  }

