import 'package:ecochallenge_mobile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  double _passwordStrength = 0;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = UserRegisterRequest(
        username: _username.text,
        email: _email.text,
        passwordHash: _password.text,
        firstName: _firstName.text,
        lastName: _lastName.text,
      );

      await Provider.of<AuthProvider>(context, listen: false).register(request);

      if (mounted) {
        Navigator.of(context).pop(); // Go back to login
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String value) {
    double strength = 0;
    if (value.length >= 6) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) strength += 0.25;
    setState(() {
      _passwordStrength = strength;
    });
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.25) return Colors.red;
    if (strength < 0.5) return Colors.orange;
    if (strength < 0.75) return Colors.amber;
    return Colors.green;
  }

  String _getStrengthLabel(double strength) {
    if (strength < 0.25) return 'Weak';
    if (strength < 0.5) return 'Fair';
    if (strength < 0.75) return 'Good';
    return 'Strong';
  }

  bool _isValidEmail(String value) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_alt_1, size: 64, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the EcoChallenge community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _username,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter a username';
                      if (value.length < 4) return 'Username must be at least 4 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter an email';
                      if (!_isValidEmail(value)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    onChanged: _updatePasswordStrength,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter a password';
                      if (_passwordStrength < 0.75) return 'Use a stronger password';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(_getStrengthColor(_passwordStrength)),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password Strength: ${_getStrengthLabel(_passwordStrength)}',
                      style: TextStyle(color: _getStrengthColor(_passwordStrength)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                      prefixIcon: Icon(Icons.badge),
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                      prefixIcon: Icon(Icons.badge_outlined),
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Register', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
