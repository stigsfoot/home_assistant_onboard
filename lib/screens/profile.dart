import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_assistant_onboard/providers/mainProvider.dart';
import '../services/services.dart';
import '../screens/screens.dart';
import 'package:provider/provider.dart';
//import '../shared/shared.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/mainProvider.dart';

class ProfileScreen extends StatelessWidget {
  Future<void> deleteUserData(BuildContext ctx, AuthService auth) async {
    await auth.deleteUser();
    Navigator.of(ctx).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget showAlertDialog(BuildContext ctx, AuthService auth) {
    Widget cancelButton = FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(ctx).pop();
      },
    );
    Widget confirmButton = FlatButton(
      child: Text(
        'Confirm',
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () {
        Navigator.of(ctx).pop();
        deleteUserData(ctx, auth);
      },
    );
    return AlertDialog(
      title: Text('Are you sure ?'),
      content: Text(
          'This will delete all your data stored. Are you sure you want to proceed ?'),
      actions: [
        cancelButton,
        confirmButton,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    final providerData = Provider.of<MainProvider>(context, listen: false);
    final AuthService auth = providerData.auth;
    final int numberOfReminders = providerData.selectedAssets.length;

    if (user != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text(user.displayName + ' of Winterfell ' ?? 'Anonymous'),
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
                padding: const EdgeInsets.all(10),
                child: Text(user.email ?? '',
                    style: Theme.of(context).textTheme.caption),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text('$numberOfReminders upcoming reminders ',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                    labelText: 'Update Location',
                  ),
                ),
              ),

              Spacer(),
              FlatButton(
                  child: Text('LOGOUT'),
                  padding: EdgeInsets.all(25),
                  color: Colors.black87,
                  onPressed: () async {
                    await auth.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }),
              Spacer(),

              // Privacy settings

              PrivacySettingsButton(
                text: 'Delete Account',
                icon: FontAwesomeIcons.trash,
                color: Colors.red,
                onPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return showAlertDialog(context, auth);
                    },
                  );
                },
                //   Navigator.of(context).push(
                //     MaterialPageRoute(builder: (ctx) {
                //       return PrivacyScreen();
                //     }),
                //   );
                // },
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.black87,
      );
      // return Text('User is not authenticated');
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
