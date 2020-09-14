import 'package:flutter/material.dart';
import 'package:home_assistant_onboard/shared/navigation.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Profile stub'),
      ),
      bottomNavigationBar: AppBottomNav(),
    );
  }
}
