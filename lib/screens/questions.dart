import 'package:flutter/material.dart';

class QuestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Onboarding questions go here'),
      ),
    );
  }
}