import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/screens.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currIndex = 0;
  List<Widget> _screens = <Widget>[
    HomeScreen(),
    Scaffold(),
    ProfileScreen(),
  ];
  void changeScreen(int index) {
    setState(() {
      _currIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF383838),
        currentIndex: _currIndex,
        // selectedItemColor: Colors.white,
        // unselectedItemColor: Colors.white.withOpacity(.50),=
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.houseUser, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendarCheck, size: 20),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userCircle, size: 20),
            label: 'Profile',
          ),
        ].toList(),
        //fixedColor: Colors.white,
        onTap: changeScreen,
      ),
    );
  }
}
