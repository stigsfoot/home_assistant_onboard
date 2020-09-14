import 'package:flutter/material.dart';
import 'package:home_assistant_onboard/shared/navigation.dart';

class QuestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Onboarding questions go here'),
      
      ),
      bottomNavigationBar: AppBottomNav(),
    );
  }
}