import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBottomNav extends StatelessWidget {
  // ref https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.houseUser, size: 25),

            title: Text('Assets')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendarCheck, size: 25),
            title: Text('Reminders')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userCircle, size: 25),
            title: Text('Profile')),
      ].toList(),
      fixedColor: Colors.white,

      
      onTap: (int navIndex) {
        switch (navIndex) {
          case 0:
            //Navigator.pushNamed(context, '/onboarding'); // TODO: commented out to possibly solve the nav issue
            break;
          case 1:
            Navigator.pushNamed(context, '/reminders');
            break;
          case 2:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }
}