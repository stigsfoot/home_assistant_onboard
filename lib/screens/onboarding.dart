import 'package:flutter/material.dart';
import 'package:home_assistant_onboard/shared/navigation.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Onboarding custom widget'),
      ),
      bottomNavigationBar: AppBottomNav(),
    );
  }
}