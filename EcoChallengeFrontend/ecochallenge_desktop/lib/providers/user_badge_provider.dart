import 'package:ecochallenge_desktop/models/user_badge.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';

class UserBadgeProvider extends BaseProvider<UserBadgeResponse> {
  UserBadgeProvider() : super("UserBadge");

  @override
  UserBadgeResponse fromJson(data) {
    return UserBadgeResponse.fromJson(data);
  }

  // Add method to get all user badges for dropdown usage
  Future<List<UserBadgeResponse>> getAllUserBadges() async {
    try {
      final result = await get();
      return result.items ?? [];
    } catch (e) {
      throw Exception("Failed to get user badges: $e");
    }
  }
}
