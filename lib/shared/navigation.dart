import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF383838),
      // selectedItemColor: Colors.white,
      // unselectedItemColor: Colors.white.withOpacity(.50),=
      items: [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.houseUser, size: 20),
            title: Text('Home')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendarCheck, size: 20),
            title: Text('Assistant')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userCircle, size: 20),
            title: Text('Profile')),
      ].toList(),
      //fixedColor: Colors.white,
      onTap: (int navIndex) {
        switch (navIndex) {
          case 0:
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
