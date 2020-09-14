import 'package:flutter/material.dart';
import 'package:home_assistant_onboard/shared/navigation.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Assistant Login'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Login stub'),
      ),
      bottomNavigationBar: AppBottomNav(),
    );
  }
}