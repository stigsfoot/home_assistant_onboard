import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF6200EE),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(.60),
      selectedFontSize: 14,
      unselectedFontSize: 14,
      items: [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.houseUser, size: 25),
            title: Text('Home')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendarCheck,
                size: 30),
            title: Text('Assistant')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userCircle, size: 25),
            title: Text('About')),
      ].toList(),
      //fixedColor: Colors.white,
      onTap: (int navIndex) {
        switch (navIndex) {
          case 0:
            // Navigator.pushNamed(context, '/onboarding'); // TODO: commented out to possibly solve the nav issue
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
