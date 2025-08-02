import 'package:ecochallenge_mobile/models/stripe_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_mobile/models/organization.dart';
import 'package:ecochallenge_mobile/providers/stripe_provider.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';
import 'package:ecochallenge_mobile/layouts/constants.dart';

class DonationPage extends StatefulWidget {
  final Organization organization;

  const DonationPage({Key? key, required this.organization}) : super(key: key);

  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isAnonymous = false;
  bool _isProcessing = false;
  
  // Predefined amounts
  final List<double> _predefinedAmounts = [10, 25, 50, 100, 200];
  double? _selectedAmount;

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stripeProvider = Provider.of<StripeProvider>(context, listen: false);

    if (authProvider.currentUserId == null) {
      _showErrorDialog('Please log in to make a donation');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      
      // Create payment intent
      final paymentRequest = StripePaymentRequest(
        userId: authProvider.currentUserId!,
        organizationId: widget.organization.id,
        amount: amount,
        currency: 'BAM',
        donationMessage: _messageController.text.isEmpty ? null : _messageController.text,
        isAnonymous: _isAnonymous,
      );

      final paymentResponse = await stripeProvider.createPaymentIntent(paymentRequest);

      // Initialize payment sheet
      await stripeProvider.initializePaymentSheet(
        clientSecret: paymentResponse.clientSecret,
        merchantDisplayName: widget.organization.name ?? 'EcoChallenge',
      );

      // Process payment
      final success = await stripeProvider.processPayment(
        clientSecret: paymentResponse.clientSecret,
        context: context,
      );

      if (success) {
        // Confirm payment on backend
        await stripeProvider.confirmPayment(paymentResponse.paymentIntentId);
        
        _showSuccessDialog(amount);
      }
    } catch (e) {
      print('Donation error: $e');
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Donation Successful!'),
            ],
          ),
          content: Text(
            'Thank you for your donation of ${amount.toStringAsFixed(2)} BAM to ${widget.organization.name}!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Payment Failed'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Make a Donation'),
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Organization Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donating to:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.organization.name ?? 'Organization',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.organization.category != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.organization.category!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Amount Selection
              const Text(
                'Select Amount (BAM)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Predefined amounts
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _predefinedAmounts.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return GestureDetector(
                    onTap: () => _selectAmount(amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2D5016) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2D5016) : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        '${amount.toInt()} BAM',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Custom amount input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Custom Amount (BAM)',
                  hintText: 'Enter amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D5016)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount < 1) {
                    return 'Minimum donation is 1 BAM';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedAmount = null; // Clear predefined selection
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message (Optional)',
                  hintText: 'Add a message with your donation',
                  prefixIcon: const Icon(Icons.message),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D5016)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Anonymous checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF2D5016),
                  ),
                  const Expanded(
                    child: Text(
                      'Make this donation anonymous',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Donate button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5016),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Donate with Stripe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Security info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment is secured by Stripe. We never store your card details.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}