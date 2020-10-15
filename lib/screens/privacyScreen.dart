import 'package:flutter/material.dart';
import '../services/services.dart';
import 'package:provider/provider.dart';
import '../providers/mainProvider.dart';

class PrivacyScreen extends StatelessWidget {
  Future<void> deleteUserData(BuildContext ctx, AuthService auth) async {
    try {
      await auth.deleteUser(ctx);
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
        'Confirm',
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () {
        Navigator.of(ctx).pop();
      },
    );
    return AlertDialog(
      title: Text('Are you sure ?'),
      content: Text(
          'This is a sensitive action and requires recent login. Please logout, and then re-login again, and try again.'),
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

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context, listen: false);
    final AuthService auth = providerData.auth;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('Privacy Settings'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: FlatButton(
            padding: EdgeInsets.all(30),
            color: Colors.red[300],
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return showAlertDialog(context, auth);
                },
              );
            },
            child: Text('DELETE MY INFORMATION', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
