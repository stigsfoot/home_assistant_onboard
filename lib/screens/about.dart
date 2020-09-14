import 'package:flutter/material.dart';
import 'package:home_assistant_onboard/shared/navigation.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('About the Home Assistant App'),
      ),
      bottomNavigationBar: AppBottomNav(),
    );
  }
}