import 'package:flutter/material.dart';

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
    );
  }
}