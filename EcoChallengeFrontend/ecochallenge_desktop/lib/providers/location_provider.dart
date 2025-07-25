import 'package:ecochallenge_desktop/models/location.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';

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
}
