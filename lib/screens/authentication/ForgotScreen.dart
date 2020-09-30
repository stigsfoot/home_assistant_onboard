import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotScreen();
  }
}

class _ForgotScreen extends State<ForgotScreen> {
  String email = "";
  var _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000725),
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50, left: 50, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  "We will mail you a link ... Please click on that link to reset your password",
                  style: TextStyle(color: Color(0xffffffff), fontSize: 20),
                ),
                Theme(
                  data: ThemeData(hintColor: Colors.blue),
                  child: Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return "please enter your email";
                        } else {
                          email = value;
                        }
                        return null;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 1)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 1)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 1)),
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email)
                              .then((value) => print("check your mail"));
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.greenAccent,
                      child: Text(
                        "Send Email",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      padding: EdgeInsets.all(10),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
