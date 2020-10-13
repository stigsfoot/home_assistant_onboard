import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_assistant_onboard/providers/mainProvider.dart';
import '../services/services.dart';
import '../screens/screens.dart';
import 'package:provider/provider.dart';
//import '../shared/shared.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/mainProvider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController textController = TextEditingController();

  Future<void> deleteUserData(BuildContext ctx, AuthService auth) async {
    try {
      await auth.deleteUser();
      Navigator.of(ctx).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      showDialog(
        context: ctx,
        builder: (BuildContext ctx) {
          return showRetryDialog(ctx, auth);
        },
      );
    }
  }

  Widget showRetryDialog(BuildContext ctx, AuthService auth) {
    Widget confirmButton = FlatButton(
      child: Text(
        'Ok',
      ),
      onPressed: () {
        Navigator.of(ctx).pop();
      },
    );
    return AlertDialog(
      title: Text('Please Re-Login !'),
      content: Text(
          'This is a sensitive action and requires recent authentication. Please logout, and then re-login again, and try again.'),
      actions: [
        confirmButton,
      ],
    );
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

  void changeNotificationRecieveValue(bool value, MainProvider providerData) {
    setState(
      () {
        providerData.recieveNotifications = value;
        providerData.changeNotificationStatus();
        print(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    final providerData = Provider.of<MainProvider>(context, listen: true);
    final AuthService auth = providerData.auth;
    final int numberOfReminders = providerData.selectedAssets.length;

    void submitAddress() {
      print('Submitting Address...');
      final address = textController.value.text.trim();
      if (address != '') {
        providerData.address = address;
        providerData.setAddress();
        setState(() {});
      } else {
        print('Address is Empty...');
      }
    }

    Widget returnAddress() {
      if (providerData.address != null && providerData.address != '') {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/editAddress');
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              providerData.address,
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        print(providerData.address);
        print(providerData.address);
        return Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: textController,
            onEditingComplete: submitAddress,
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
              labelText: 'Update Address',
            ),
          ),
        );
      }
    }

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

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: TextField(
              //     controller: textController,
              //     onEditingComplete: submitAddress,
              //     obscureText: false,
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(),
              //       prefixIcon: Icon(Icons.home),
              //       labelText: 'Update Location',
              //     ),
              //   ),
              // ),
              returnAddress(),

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
              SwitchListTile(
                value: providerData.recieveNotifications,
                onChanged: (value) {
                  changeNotificationRecieveValue(value, providerData);
                },
                title: Text('Recieve Notifications'),
              ),
              SizedBox(
                height: 10,
              ),
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
          // color: Colors.black87,
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
