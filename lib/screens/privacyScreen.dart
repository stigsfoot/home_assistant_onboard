import 'package:flutter/material.dart';
import '../services/services.dart';

class PrivacyScreen extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
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
            color: Colors.blue[200],
            onPressed: () async {
              await auth.deleteUser();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: Expanded(
              child: Text('DELETE MY DATA', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
