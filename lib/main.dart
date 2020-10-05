// Automagically imported
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_assistant_onboard/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:home_assistant_onboard/services/services.dart';
import './providers/mainProvider.dart';

// fewer lines
// import 'screens/screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(value: AuthService().user),
        ChangeNotifierProvider(
          create: (BuildContext ctx) => MainProvider(),
        ),
      ],
      child: MaterialApp(
        // Firebase Analytics
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
        ],

        //Routes
        routes: {
          '/': (context) => LoginScreen(),
          //'/about': (context) => AboutScreen(),
          '/profile': (context) => ProfileScreen(),
          //'/reminders': (context) => RemindersScreen(),
          '/onboarding': (context) => OnboardingScreen(),
          '/addAsset': (context) => AddAsset(),
          '/editAsset': (context) => EditScreen(),
        },

        // Theme
        theme: ThemeData(
          fontFamily: 'Nunito',
          bottomAppBarTheme: BottomAppBarTheme(
            color: Colors.black87,
          ),
          brightness: Brightness.dark,
          textTheme: TextTheme(
            button: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          buttonTheme: ButtonThemeData(),
        ),
      ),
    );
  }
}
