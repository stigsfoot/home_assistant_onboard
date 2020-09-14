import 'package:flutter/material.dart';
import 'package:home_assistant_onboard/shared/navigation.dart';

class RemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Asset Reminders'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('List of home maintenance related reminders'),
      ),
      bottomNavigationBar: AppBottomNav(),
    );
  }
}