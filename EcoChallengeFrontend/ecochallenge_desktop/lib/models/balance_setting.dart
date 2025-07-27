import 'package:ecochallenge_desktop/models/search_result.dart';

// Balance Setting Response Model
class BalanceSettingResponse {
  final int id;
  final double wholeBalance;
  final double balanceLeft;
  final DateTime updatedAt;
  final String? updatedByName;

  BalanceSettingResponse({
    required this.id,
    required this.wholeBalance,
    required this.balanceLeft,
    required this.updatedAt,
    this.updatedByName,
  });

  factory BalanceSettingResponse.fromJson(Map<String, dynamic> json) {
    return BalanceSettingResponse(
      id: json['id'],
      wholeBalance: (json['wholeBalance'] as num).toDouble(),
      balanceLeft: (json['balanceLeft'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt']),
      updatedByName: json['updatedByName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wholeBalance': wholeBalance,
      'balanceLeft': balanceLeft,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedByName': updatedByName,
    };
  }

  // Helper method to get balance percentage
  double get balancePercentage {
    if (wholeBalance == 0) return 0.0;
    return (balanceLeft / wholeBalance) * 100;
  }

  // Helper method to get used balance
  double get usedBalance {
    return wholeBalance - balanceLeft;
  }

  // Helper method to check if balance is low (less than 20%)
  bool get isLowBalance {
    return balancePercentage < 20;
  }

  // Helper method to check if balance is critical (less than 10%)
  bool get isCriticalBalance {
    return balancePercentage < 10;
  }
}

// Balance Setting Insert Request Model
class BalanceSettingInsertRequest {
  final double wholeBalance;
  final double balanceLeft;
  final int? updatedByAdminId;

  BalanceSettingInsertRequest({
    required this.wholeBalance,
    required this.balanceLeft,
    this.updatedByAdminId,
  });

  Map<String, dynamic> toJson() {
    return {
      'wholeBalance': wholeBalance,
      'balanceLeft': balanceLeft,
      'updatedByAdminId': updatedByAdminId,
    };
  }
}

// Balance Setting Update Request Model
class BalanceSettingUpdateRequest {
  final int id;
  final double wholeBalance;
  final double balanceLeft;
  final int? updatedByAdminId;

  BalanceSettingUpdateRequest({
    required this.id,
    required this.wholeBalance,
    required this.balanceLeft,
    this.updatedByAdminId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wholeBalance': wholeBalance,
      'balanceLeft': balanceLeft,
      'updatedByAdminId': updatedByAdminId,
    };
  }
}

// Balance Setting Search Object
class BalanceSettingSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  // Future filters can be added here if needed
  DateTime? fromDate;
  DateTime? toDate;
  int? updatedByAdminId;
  double? minBalance;
  double? maxBalance;

  BalanceSettingSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.fromDate,
    this.toDate,
    this.updatedByAdminId,
    this.minBalance,
    this.maxBalance,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'desc': desc,
      'includeTotalCount': includeTotalCount,
      'retrieveAll': retrieveAll,
    };

    if (fromDate != null) data['fromDate'] = fromDate!.toIso8601String();
    if (toDate != null) data['toDate'] = toDate!.toIso8601String();
    if (updatedByAdminId != null) data['updatedByAdminId'] = updatedByAdminId;
    if (minBalance != null) data['minBalance'] = minBalance;
    if (maxBalance != null) data['maxBalance'] = maxBalance;

    return data;
  }
}

// Balance Transaction Model (for tracking balance changes)
class BalanceTransaction {
  final int id;
  final double previousBalance;
  final double newBalance;
  final double changeAmount;
  final String changeType; // 'increase', 'decrease', 'reset'
  final String? reason;
  final int? adminId;
  final String? adminName;
  final DateTime createdAt;

  BalanceTransaction({
    required this.id,
    required this.previousBalance,
    required this.newBalance,
    required this.changeAmount,
    required this.changeType,
    this.reason,
    this.adminId,
    this.adminName,
    required this.createdAt,
  });

  factory BalanceTransaction.fromJson(Map<String, dynamic> json) {
    return BalanceTransaction(
      id: json['id'],
      previousBalance: (json['previousBalance'] as num).toDouble(),
      newBalance: (json['newBalance'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      changeType: json['changeType'],
      reason: json['reason'],
      adminId: json['adminId'],
      adminName: json['adminName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'previousBalance': previousBalance,
      'newBalance': newBalance,
      'changeAmount': changeAmount,
      'changeType': changeType,
      'reason': reason,
      'adminId': adminId,
      'adminName': adminName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
