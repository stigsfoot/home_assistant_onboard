import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../services/services.dart';
import '../../providers/mainProvider.dart';

class LoginScreen extends StatefulWidget {
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  AuthService auth;

  @override
  void initState() {
    super.initState();
    final providerData = Provider.of<MainProvider>(context, listen: false);
    auth = providerData.auth;
    auth.getUser.then(
      (user) {
        if (user != null) {
          /// Update user last Online, each time
          /// the user opens the App, if the user is logged in.
          auth.updateUserData(user);
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      },
    );
    providerData.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlutterLogo(
              size: 150,
            ),

            Text(
              'Welcome',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            Text('Home Assistant remembers so you do not have to.'),

            // Button
            LoginButton(
              text: 'LOGIN WITH GOOGLE',
              icon: FontAwesomeIcons.google,
              color: Colors.black45,
              loginMethod: auth.googleSignIn,
            ),

            // Privacy settings
            PrivacySettingsButton(
              text: 'Update privacy settings',
              icon: FontAwesomeIcons.cog,
              color: Colors.lightGreen,
              onPress: () {},
            ),

            Text(
              'You can return to review and update your privacy settings.',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
            // This was causing the null
            // I have commented it out.
            // PrivacySettingsButton(),
            LoginButton(
              text: 'Access without logging in',
              // TODO: Implement this !
              // Implement properly, User always gets created, even as anon
              // Error on Profile Screen, as Name in null
              // loginMethod: auth.anonLogin,
              loginMethod: () {},
            )
          ],
        ),
      ),
    );
  }
}

// Login widget we can reuse
class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  const LoginButton(
      {Key key, this.text, this.icon, this.color, this.loginMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: () async {
          var user = await loginMethod();
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/onboarding');
          }
        },
        label: Expanded(
          child: Text('$text', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

// Privacy Settings widget
class PrivacySettingsButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function onPress;

  const PrivacySettingsButton(
      {Key key, this.text, this.icon, this.color, this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 0),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: () {
          onPress();
          //TODO: insert privacy overlay
        },
        label: Expanded(
          child: Text('$text', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
