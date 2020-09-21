import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import '../screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:home_assistant_onboard/shared/navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);

    if (user != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text(
              'House ' + user.displayName + ' of Winterfell ' ?? 'Anonymous'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (user.photoUrl != null)
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(user.photoUrl),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text(user.email ?? '',
                    style: Theme.of(context).textTheme.caption),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text('201 North Union Street, Virginia'),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  '8 upcoming home related reminders ',
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center),
              ),
              Spacer(),

              FlatButton(
                  child: Text('Logout'),
                  padding: EdgeInsets.all(30),
                  color: Colors.black87,
                  onPressed: () async {
                    await auth.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }),
              Spacer(),

              // Privacy settings

              PrivacySettingsButton(
                text: 'Update privacy settings',
                icon: FontAwesomeIcons.cog,
                color: Colors.lightGreen,
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(),
      );
    } else {
      return Text('User is not authenticated');
    }
  }
}

// Logout
class LogoutButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const LogoutButton({Key key, this.text, this.icon, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: () {
          //TODO: insert privacy overlay
        },
        label: Expanded(
          child: Text('$text', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
