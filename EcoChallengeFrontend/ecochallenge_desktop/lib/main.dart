import 'package:ecochallenge_desktop/providers/admin_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AdminAuthProvider();
  await authProvider.loadCredentials();

  runApp(
    ChangeNotifierProvider<AdminAuthProvider>.value(
      value: authProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AdminAuthProvider>(context);
    return MaterialApp(
      home: auth.isLoggedIn ? AdminDashboardPage() : AdminLoginPage(),
    );
  }
}

