import 'package:ecochallenge_desktop/models/search_result.dart';

// Donation Response Model
class DonationResponse {
  final int id;
  final int userId;
  final int organizationId;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? paymentReference;
  final String? donationMessage;
  final bool isAnonymous;
  final int statusId;
  final int pointsEarned;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? userName;
  final String? organizationName;

  DonationResponse({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.paymentReference,
    this.donationMessage,
    required this.isAnonymous,
    required this.statusId,
    required this.pointsEarned,
    required this.createdAt,
    this.processedAt,
    this.userName,
    this.organizationName,
  });

  factory DonationResponse.fromJson(Map<String, dynamic> json) {
    return DonationResponse(
      id: json['id'],
      userId: json['userId'],
      organizationId: json['organizationId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'BAM',
      paymentMethod: json['paymentMethod'],
      paymentReference: json['paymentReference'],
      donationMessage: json['donationMessage'],
      isAnonymous: json['isAnonymous'] ?? false,
      statusId: json['statusId'],
      pointsEarned: json['pointsEarned'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      userName: json['userName'],
      organizationName: json['organizationName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'organizationId': organizationId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'donationMessage': donationMessage,
      'isAnonymous': isAnonymous,
      'statusId': statusId,
      'pointsEarned': pointsEarned,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'userName': userName,
      'organizationName': organizationName,
    };
  }
}

// Donation Insert Request Model
class DonationInsertRequest {
  final int userId;
  final int organizationId;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? paymentReference;
  final String? donationMessage;
  final bool isAnonymous;
  final int statusId;
  final int pointsEarned;

  DonationInsertRequest({
    required this.userId,
    required this.organizationId,
    required this.amount,
    this.currency = 'BAM',
    this.paymentMethod,
    this.paymentReference,
    this.donationMessage,
    this.isAnonymous = false,
    required this.statusId,
    this.pointsEarned = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'organizationId': organizationId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'donationMessage': donationMessage,
      'isAnonymous': isAnonymous,
      'statusId': statusId,
      'pointsEarned': pointsEarned,
    };
  }
}

// Donation Update Request Model
class DonationUpdateRequest {
  final int id;
  final int? userId;
  final int? organizationId;
  final double? amount;
  final String? currency;
  final String? paymentMethod;
  final String? paymentReference;
  final String? donationMessage;
  final bool? isAnonymous;
  final int? statusId;
  final int? pointsEarned;
  final DateTime? processedAt;

  DonationUpdateRequest({
    required this.id,
    this.userId,
    this.organizationId,
    this.amount,
    this.currency,
    this.paymentMethod,
    this.paymentReference,
    this.donationMessage,
    this.isAnonymous,
    this.statusId,
    this.pointsEarned,
    this.processedAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (userId != null) data['userId'] = userId;
    if (organizationId != null) data['organizationId'] = organizationId;
    if (amount != null) data['amount'] = amount;
    if (currency != null) data['currency'] = currency;
    if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
    if (paymentReference != null) data['paymentReference'] = paymentReference;
    if (donationMessage != null) data['donationMessage'] = donationMessage;
    if (isAnonymous != null) data['isAnonymous'] = isAnonymous;
    if (statusId != null) data['statusId'] = statusId;
    if (pointsEarned != null) data['pointsEarned'] = pointsEarned;
    if (processedAt != null) data['processedAt'] = processedAt!.toIso8601String();
    
    return data;
  }
}

// Donation Search Object
class DonationSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? userId;
  int? organizationId;
  int? statusId;
  bool? isAnonymous;
  double? minAmount;
  double? maxAmount;

  DonationSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.userId,
    this.organizationId,
    this.statusId,
    this.isAnonymous,
    this.minAmount,
    this.maxAmount,
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

    if (userId != null) data['userId'] = userId;
    if (organizationId != null) data['organizationId'] = organizationId;
    if (statusId != null) data['statusId'] = statusId;
    if (isAnonymous != null) data['isAnonymous'] = isAnonymous;
    if (minAmount != null) data['minAmount'] = minAmount;
    if (maxAmount != null) data['maxAmount'] = maxAmount;

    return data;
  }
}
