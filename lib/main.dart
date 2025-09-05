import 'package:flutter/material.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/location/presentation/location_screen.dart';
import 'features/alarms/presentation/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nature Sync Alarm',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/location': (context) => const LocationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
