import 'package:ecochallenge_mobile/pages/cleanup_map_page.dart';
import 'package:ecochallenge_mobile/pages/events_list_page.dart';
import 'package:ecochallenge_mobile/pages/gallery_page.dart';
import 'package:ecochallenge_mobile/pages/home_page.dart';
import 'package:ecochallenge_mobile/pages/login_page.dart';
import 'package:ecochallenge_mobile/pages/register_page.dart';
import 'package:ecochallenge_mobile/providers/badge_provider.dart';
import 'package:ecochallenge_mobile/providers/event_participant_provider.dart';
import 'package:ecochallenge_mobile/providers/event_provider.dart';
import 'package:ecochallenge_mobile/providers/gallery_reaction_provider.dart';
import 'package:ecochallenge_mobile/providers/gallery_showcase_provider.dart';
import 'package:ecochallenge_mobile/providers/location_provider.dart';
import 'package:ecochallenge_mobile/providers/organization_provider.dart';
import 'package:ecochallenge_mobile/providers/request_participation_provider.dart';
import 'package:ecochallenge_mobile/providers/request_provider.dart';
import 'package:ecochallenge_mobile/providers/stripe_provider.dart';
import 'package:ecochallenge_mobile/providers/user_badge_provider.dart';
import 'package:ecochallenge_mobile/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadCredentials();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => GalleryShowcaseProvider()), 
        ChangeNotifierProvider(create: (_) => GalleryReactionProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
        ChangeNotifierProvider(create: (_) => UserBadgeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventParticipantProvider()),
        ChangeNotifierProvider(create: (_) => StripeProvider()),
        ChangeNotifierProvider(create: (_) => RequestParticipationProvider()),
        // Add more providers here if needed
      ],
      child: MyApp(initialRoute: authProvider.isLoggedIn ? '/home' : '/login'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoChallenge App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/gallery': (context) => GalleryPage(),
        '/cleanup-map': (context) => const CleanupMapPage(),
        '/events': (context) => EventsListPage(),
      },
    );
  }
}
