import 'package:flutter/material.dart';
import '../shared/shared.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About this pre-release'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Let me know if you have any feedback.'),
      ),
      bottomNavigationBar: AppBottomNav(),
    );
  }
}
