import 'package:ecochallenge_desktop/models/reward.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:ecochallenge_desktop/models/search_result.dart';

class RewardProvider extends BaseProvider<RewardResponse> {
  RewardProvider() : super("Reward");

  @override
  RewardResponse fromJson(data) {
    return RewardResponse.fromJson(data);
  }

  // Get rewards with search filters
  Future<SearchResult<RewardResponse>> getRewards({RewardSearchObject? searchObject}) async {
    try {
      final result = await get(filter: searchObject?.toJson());
      return result;
    } catch (e) {
      throw Exception("Failed to get rewards: $e");
    }
  }

  // Insert new reward
  Future<RewardResponse> insertReward(RewardInsertRequest request) async {
    try {
      return await insert(request.toJson());
    } catch (e) {
      throw Exception("Failed to insert reward: $e");
    }
  }

  // Update existing reward
  Future<RewardResponse> updateReward(RewardUpdateRequest request) async {
    try {
      return await update(request.id, request.toJson());
    } catch (e) {
      throw Exception("Failed to update reward: $e");
    }
  }

  // Delete reward
  Future<void> deleteReward(int id) async {
    try {
      await delete(id);
    } catch (e) {
      throw Exception("Failed to delete reward: $e");
    }
  }

  // Get reward by ID
  Future<RewardResponse> getRewardById(int id) async {
    try {
      return await getById(id);
    } catch (e) {
      throw Exception("Failed to get reward: $e");
    }
  }

  // Approve reward
  Future<RewardResponse> approveReward(int id, int adminId) async {
    try {
      final updateRequest = RewardUpdateRequest(
        id: id,
        status: RewardStatus.approved,
        approvedByAdminId: adminId,
        approvedAt: DateTime.now(),
      );
      return await updateReward(updateRequest);
    } catch (e) {
      throw Exception("Failed to approve reward: $e");
    }
  }

  // Reject reward
  Future<RewardResponse> rejectReward(int id, int adminId) async {
    try {
      final updateRequest = RewardUpdateRequest(
        id: id,
        status: RewardStatus.rejected,
        approvedByAdminId: adminId,
        approvedAt: DateTime.now(),
      );
      return await updateReward(updateRequest);
    } catch (e) {
      throw Exception("Failed to reject reward: $e");
    }
  }
}
