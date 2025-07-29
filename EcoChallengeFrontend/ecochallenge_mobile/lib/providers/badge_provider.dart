import 'package:ecochallenge_mobile/models/badge.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class BadgeProvider extends BaseProvider<BadgeResponse> {
  BadgeProvider() : super("Badge");

  @override
  BadgeResponse fromJson(data) {
    return BadgeResponse.fromJson(data);
  }

  // Add method to get all badges for dropdown usage
  Future<List<BadgeResponse>> getAllBadges() async {
    try {
      final result = await get();
      return result.items ?? [];
    } catch (e) {
      throw Exception("Failed to get badges: $e");
    }
  }
}
