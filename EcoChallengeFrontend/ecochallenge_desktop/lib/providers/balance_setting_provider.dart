import 'package:ecochallenge_desktop/models/balance_setting.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:ecochallenge_desktop/models/search_result.dart';

class BalanceSettingProvider extends BaseProvider<BalanceSettingResponse> {
  BalanceSettingProvider() : super("BalanceSetting");

  @override
  BalanceSettingResponse fromJson(data) {
    return BalanceSettingResponse.fromJson(data);
  }

  // Get balance settings with search filters
  Future<SearchResult<BalanceSettingResponse>> getBalanceSettings({BalanceSettingSearchObject? searchObject}) async {
    try {
      final result = await get(filter: searchObject?.toJson());
      return result;
    } catch (e) {
      throw Exception("Failed to get balance settings: $e");
    }
  }

  // Insert new balance setting
  Future<BalanceSettingResponse> insertBalanceSetting(BalanceSettingInsertRequest request) async {
    try {
      return await insert(request.toJson());
    } catch (e) {
      throw Exception("Failed to insert balance setting: $e");
    }
  }

  // Update existing balance setting
  Future<BalanceSettingResponse> updateBalanceSetting(BalanceSettingUpdateRequest request) async {
    try {
      return await update(request.id, request.toJson());
    } catch (e) {
      throw Exception("Failed to update balance setting: $e");
    }
  }

  // Delete balance setting
  Future<void> deleteBalanceSetting(int id) async {
    try {
      await delete(id);
    } catch (e) {
      throw Exception("Failed to delete balance setting: $e");
    }
  }

  // Get balance setting by ID
  Future<BalanceSettingResponse> getBalanceSettingById(int id) async {
    try {
      return await getById(id);
    } catch (e) {
      throw Exception("Failed to get balance setting: $e");
    }
  }

  // Get current/latest balance setting
  Future<BalanceSettingResponse?> getCurrentBalance() async {
    try {
      final searchObject = BalanceSettingSearchObject(
        pageSize: 1,
        sortBy: "UpdatedAt",
        desc: true,
      );
      final result = await getBalanceSettings(searchObject: searchObject);
      
      if (result.items != null && result.items!.isNotEmpty) {
        return result.items!.first;
      }
      return null;
    } catch (e) {
      throw Exception("Failed to get current balance: $e");
    }
  }

  // Add balance (increase whole balance and balance left)
  Future<BalanceSettingResponse> addBalance(double amount, int adminId, {String? reason}) async {
    try {
      final currentBalance = await getCurrentBalance();
      if (currentBalance == null) {
        // Create initial balance if none exists
        final insertRequest = BalanceSettingInsertRequest(
          wholeBalance: amount,
          balanceLeft: amount,
          updatedByAdminId: adminId,
        );
        return await insertBalanceSetting(insertRequest);
      } else {
        // Update existing balance
        final updateRequest = BalanceSettingUpdateRequest(
          id: currentBalance.id,
          wholeBalance: currentBalance.wholeBalance + amount,
          balanceLeft: currentBalance.balanceLeft + amount,
          updatedByAdminId: adminId,
        );
        return await updateBalanceSetting(updateRequest);
      }
    } catch (e) {
      throw Exception("Failed to add balance: $e");
    }
  }

  // Deduct balance (decrease balance left only)
  Future<BalanceSettingResponse> deductBalance(double amount, int adminId, {String? reason}) async {
    try {
      final currentBalance = await getCurrentBalance();
      if (currentBalance == null) {
        throw Exception("No balance setting found");
      }

      if (currentBalance.balanceLeft < amount) {
        throw Exception("Insufficient balance. Available: ${currentBalance.balanceLeft}, Requested: $amount");
      }

      final updateRequest = BalanceSettingUpdateRequest(
        id: currentBalance.id,
        wholeBalance: currentBalance.wholeBalance,
        balanceLeft: currentBalance.balanceLeft - amount,
        updatedByAdminId: adminId,
      );
      return await updateBalanceSetting(updateRequest);
    } catch (e) {
      throw Exception("Failed to deduct balance: $e");
    }
  }

  // Reset balance (set both whole balance and balance left to new amount)
  Future<BalanceSettingResponse> resetBalance(double newAmount, int adminId, {String? reason}) async {
    try {
      final currentBalance = await getCurrentBalance();
      if (currentBalance == null) {
        // Create initial balance if none exists
        final insertRequest = BalanceSettingInsertRequest(
          wholeBalance: newAmount,
          balanceLeft: newAmount,
          updatedByAdminId: adminId,
        );
        return await insertBalanceSetting(insertRequest);
      } else {
        // Update existing balance
        final updateRequest = BalanceSettingUpdateRequest(
          id: currentBalance.id,
          wholeBalance: newAmount,
          balanceLeft: newAmount,
          updatedByAdminId: adminId,
        );
        return await updateBalanceSetting(updateRequest);
      }
    } catch (e) {
      throw Exception("Failed to reset balance: $e");
    }
  }

  // Adjust balance left only (for corrections)
  Future<BalanceSettingResponse> adjustBalanceLeft(double newBalanceLeft, int adminId, {String? reason}) async {
    try {
      final currentBalance = await getCurrentBalance();
      if (currentBalance == null) {
        throw Exception("No balance setting found");
      }

      if (newBalanceLeft > currentBalance.wholeBalance) {
        throw Exception("Balance left cannot exceed whole balance");
      }

      if (newBalanceLeft < 0) {
        throw Exception("Balance left cannot be negative");
      }

      final updateRequest = BalanceSettingUpdateRequest(
        id: currentBalance.id,
        wholeBalance: currentBalance.wholeBalance,
        balanceLeft: newBalanceLeft,
        updatedByAdminId: adminId,
      );
      return await updateBalanceSetting(updateRequest);
    } catch (e) {
      throw Exception("Failed to adjust balance: $e");
    }
  }

  // Get balance history (all balance settings ordered by date)
  Future<SearchResult<BalanceSettingResponse>> getBalanceHistory({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final searchObject = BalanceSettingSearchObject(
        page: page,
        pageSize: pageSize,
        sortBy: "UpdatedAt",
        desc: true,
      );
      return await getBalanceSettings(searchObject: searchObject);
    } catch (e) {
      throw Exception("Failed to get balance history: $e");
    }
  }

  // Check if balance is low (less than specified threshold)
  Future<bool> isBalanceLow({double threshold = 1000.0}) async {
    try {
      final currentBalance = await getCurrentBalance();
      if (currentBalance == null) return true;
      return currentBalance.balanceLeft < threshold;
    } catch (e) {
      throw Exception("Failed to check balance status: $e");
    }
  }

  // Get balance statistics
  Future<Map<String, dynamic>> getBalanceStatistics() async {
    try {
      final currentBalance = await getCurrentBalance();
      if (currentBalance == null) {
        return {
          'wholeBalance': 0.0,
          'balanceLeft': 0.0,
          'usedBalance': 0.0,
          'usagePercentage': 0.0,
          'isLowBalance': true,
          'isCriticalBalance': true,
        };
      }

      return {
        'wholeBalance': currentBalance.wholeBalance,
        'balanceLeft': currentBalance.balanceLeft,
        'usedBalance': currentBalance.usedBalance,
        'usagePercentage': 100 - currentBalance.balancePercentage,
        'balancePercentage': currentBalance.balancePercentage,
        'isLowBalance': currentBalance.isLowBalance,
        'isCriticalBalance': currentBalance.isCriticalBalance,
        'lastUpdated': currentBalance.updatedAt,
        'updatedBy': currentBalance.updatedByName,
      };
    } catch (e) {
      throw Exception("Failed to get balance statistics: $e");
    }
  }

  // Validate balance operation
  bool validateBalanceOperation(double currentBalance, double operationAmount, String operationType) {
    switch (operationType.toLowerCase()) {
      case 'deduct':
        return currentBalance >= operationAmount;
      case 'add':
      case 'reset':
        return operationAmount >= 0;
      default:
        return false;
    }
  }

  // Format balance for display
  String formatBalance(double balance, {String currency = 'BAM'}) {
    return '${balance.toStringAsFixed(2)} $currency';
  }
}
