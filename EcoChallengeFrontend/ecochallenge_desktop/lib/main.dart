import 'package:ecochallenge_desktop/providers/admin_auth_provider.dart';
import 'package:ecochallenge_desktop/providers/balance_setting_provider.dart';
import 'package:ecochallenge_desktop/providers/gallery_showcase_provider.dart';
import 'package:ecochallenge_desktop/providers/request_participation_provider.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';
import 'package:ecochallenge_desktop/providers/request_provider.dart';
import 'package:ecochallenge_desktop/providers/donation_provider.dart';
import 'package:ecochallenge_desktop/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AdminAuthProvider();
  await authProvider.loadCredentials();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminAuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RequestParticipationProvider()),
        ChangeNotifierProvider(create: (_) => BalanceSettingProvider()),
        ChangeNotifierProvider(create: (_) => GalleryShowcaseProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AdminAuthProvider>(context);
    return MaterialApp(
      title: 'EcoChallenge Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: auth.isLoggedIn ? AdminDashboardPage() : AdminLoginPage(),
    );
  }
}