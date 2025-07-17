import 'package:flutter/material.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_dashboard_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminLoginPage(),
      routes: {'/admin-dashboard': (context) => AdminDashboardPage()},
    );
  }
}
