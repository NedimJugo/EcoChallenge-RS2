
import 'package:ecochallenge_desktop/models/user_type.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';


class UserTypeProvider extends BaseProvider<UserType> {
  UserTypeProvider() : super("UserType");

  @override
  UserType fromJson(data) {
    return UserType.fromJson(data);
  }

  // Add method to get all user types for dropdown usage
  Future<List<UserType>> getAllUserTypes() async {
    try {
      final result = await get();
      return result.items ?? []; // Handle null case
    } catch (e) {
      throw Exception("Failed to get user types: $e");
    }
  }

  // The delete and getById methods are now inherited from BaseProvider
  // You can add user-type-specific methods here if needed
}
