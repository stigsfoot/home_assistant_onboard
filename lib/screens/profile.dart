import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('This is the profile screen'),
      ),
    );
  }
}