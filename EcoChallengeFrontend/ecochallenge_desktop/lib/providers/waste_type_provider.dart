import 'package:ecochallenge_desktop/models/waste_type.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';

class WasteTypeProvider extends BaseProvider<WasteTypeResponse> {
  WasteTypeProvider() : super("WasteType");

  @override
  WasteTypeResponse fromJson(data) {
    return WasteTypeResponse.fromJson(data);
  }

  // Add method to get all waste types for dropdown usage
  Future<List<WasteTypeResponse>> getAllWasteTypes() async {
    try {
      final result = await get();
      return result.items ?? [];
    } catch (e) {
      throw Exception("Failed to get waste types: $e");
    }
  }
}
