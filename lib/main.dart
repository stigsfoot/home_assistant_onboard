//import 'dart:html';

// Automagically imported
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:home_assistant_onboard/screens/reminders.dart';
import 'package:home_assistant_onboard/screens/about.dart';
import 'package:home_assistant_onboard/screens/onboarding.dart';
import 'package:home_assistant_onboard/screens/screens.dart';

// fewer lines
// import 'screens/screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Firebase Analytics
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
        ],

        routes: {
          '/': (context) => LoginScreen(),
          '/about': (context) => AboutScreen(),
          '/onboarding': (context) => OnboardingScreen(),
          '/profile': (context) => ProfileScreen(),
          '/reminders': (context) => RemindersScreen(),
        },

        // Theme
        theme: ThemeData(
            // your customizations here
            brightness: Brightness.dark,
          ),
      );
  }
}
