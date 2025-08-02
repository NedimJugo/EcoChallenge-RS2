class StripePaymentRequest {
  final int userId;
  final int organizationId;
  final double amount;
  final String currency;
  final String? donationMessage;
  final bool isAnonymous;
  final String? returnUrl;

  StripePaymentRequest({
    required this.userId,
    required this.organizationId,
    required this.amount,
    this.currency = 'BAM',
    this.donationMessage,
    this.isAnonymous = false,
    this.returnUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'organizationId': organizationId,
      'amount': amount,
      'currency': currency,
      'donationMessage': donationMessage,
      'isAnonymous': isAnonymous,
      'returnUrl': returnUrl,
    };
  }
}

class StripePaymentResponse {
  final String paymentIntentId;
  final String clientSecret;
  final String status;
  final double amount;
  final String currency;
  final int donationId;

  StripePaymentResponse({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.status,
    required this.amount,
    required this.currency,
    required this.donationId,
  });

  factory StripePaymentResponse.fromJson(Map<String, dynamic> json) {
    return StripePaymentResponse(
      paymentIntentId: json['paymentIntentId'],
      clientSecret: json['clientSecret'],
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      donationId: json['donationId'],
    );
  }
}

class StripeConfigResponse {
  final String publishableKey;

  StripeConfigResponse({required this.publishableKey});

  factory StripeConfigResponse.fromJson(Map<String, dynamic> json) {
    return StripeConfigResponse(
      publishableKey: json['publishableKey'],
    );
  }
}