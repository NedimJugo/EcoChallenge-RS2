import 'dart:convert';
import 'package:ecochallenge_mobile/models/stripe_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class StripeProvider extends BaseProvider<StripePaymentResponse> {
  bool _isInitialized = false;
  String? _publishableKey;

  StripeProvider() : super("Stripe");

  bool get isInitialized => _isInitialized;

  @override
  StripePaymentResponse fromJson(data) {
    return StripePaymentResponse.fromJson(data);
  }

  Future<void> initializeStripe() async {
    try {
      if (_isInitialized) return;

      // Get Stripe configuration from backend
      final config = await _getStripeConfig();
      _publishableKey = config.publishableKey;

      // Initialize Stripe with explicit settings
      Stripe.publishableKey = _publishableKey!;
      
      // Try alternative initialization
      await Stripe.instance.applySettings();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing Stripe: $e');
      // Don't throw here, let the payment intent creation handle it
      rethrow;
    }
  }

  Future<StripeConfigResponse> _getStripeConfig() async {
    final url = "$baseUrl/$endpoint/config";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      return StripeConfigResponse.fromJson(data);
    } else {
      throw Exception("Failed to get Stripe configuration");
    }
  }

  Future<StripePaymentResponse> createPaymentIntent(StripePaymentRequest request) async {
    try {
      if (!_isInitialized) {
        await initializeStripe();
      }

      final url = "$baseUrl/$endpoint/create-payment-intent";
      final uri = Uri.parse(url);
      final headers = createHeaders();
      headers['Content-Type'] = 'application/json';

      final jsonRequest = jsonEncode(request.toJson());
      final response = await http.post(uri, headers: headers, body: jsonRequest);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return StripePaymentResponse.fromJson(data);
      } else {
        throw Exception("Failed to create payment intent");
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      throw Exception('Failed to create payment intent: $e');
    }
  }

  Future<bool> processPayment({
    required String clientSecret,
    required BuildContext context,
  }) async {
    try {
      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      print('Stripe payment error: ${e.error}');
      
      if (e.error.code == FailureCode.Canceled) {
        // User canceled the payment
        return false;
      }
      
      throw Exception('Payment failed: ${e.error.localizedMessage}');
    } catch (e) {
      print('Payment processing error: $e');
      throw Exception('Payment processing failed: $e');
    }
  }

  Future<void> initializePaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
          billingDetails: const BillingDetails(
            // You can pre-fill user details here if available
          ),
        ),
      );
    } catch (e) {
      print('Error initializing payment sheet: $e');
      throw Exception('Failed to initialize payment sheet: $e');
    }
  }

  Future<StripePaymentResponse> confirmPayment(String paymentIntentId) async {
    try {
      final url = "$baseUrl/$endpoint/confirm-payment/$paymentIntentId";
      final uri = Uri.parse(url);
      final headers = createHeaders();

      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return StripePaymentResponse.fromJson(data);
      } else {
        throw Exception("Failed to confirm payment");
      }
    } catch (e) {
      print('Error confirming payment: $e');
      throw Exception('Failed to confirm payment: $e');
    }
  }
}