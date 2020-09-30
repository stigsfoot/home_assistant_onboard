import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home_assistant_onboard/screens/about.dart';
import 'SignUpScreen.dart';
import 'ForgotScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LogInScreen();
  }
}

class _LogInScreen extends State<LogInScreen> {
  bool signInState = false;
  String email = "", password = "";
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  String errorMessage;
  Future<bool> logIn() async {
    try{
     user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.trim(), password: password))
        .user;
    }catch(error) {
    switch (error.code) {
      
      case "ERROR_INVALID_EMAIL":
        errorMessage = "Your email address appears to be malformed.";
     
        break;
      case "ERROR_WRONG_PASSWORD":
        errorMessage = "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        errorMessage = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        errorMessage = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        errorMessage = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }
  }
    if (user.isEmailVerified) {
      return(Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    AboutScreen())));
 
}
else{
 return Future.error(errorMessage);
}
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  Future<void> _gooogleSignIn() async {
    GoogleSignInAccount signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication signInAuthentication =
        await signInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: signInAuthentication.idToken,
        accessToken: signInAuthentication.accessToken);
    FirebaseUser user = (await auth.signInWithCredential(credential)).user;
    print(user);
    if(mounted) {
    setState(() {
      signInState = true;
    });
    }
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      if (await auth.currentUser() != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => AboutScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000725),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 180,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "Log in",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 45),
                    ),
                    Text(
                      "Your Home Assistant Scheduler",
                      style: TextStyle(color: Colors.white, fontFamily: 'muso'),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(150)),
                color: Colors.greenAccent,
              ),
            ),
            Theme(
              data: ThemeData(hintColor: Colors.blue),
              child: Padding(
                padding: EdgeInsets.only(top: 50, right: 20, left: 20),
                child: TextFormField(
                validator: (value){
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    // Null check
    if(value.isEmpty){
        return 'please enter your email';
    }
    // Valid email formatting check
    else if(!regex.hasMatch(value)){
       return 'Enter valid email address';
    }
    // success condition
    else {
       email = value;
    }
    return null;
},
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                  ),
                  onSaved: (value) => email = value,
                ),
              ),
            ),
            Theme(
              data: ThemeData(hintColor: Colors.blue),
              child: Padding(
                padding: EdgeInsets.only(top: 10, right: 20, left: 20),
                child: TextFormField(
                  obscureText: true,
                  autocorrect: false,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter your password";
                    } else {
                      password = value;
                      
                    }
                    
                    return null;
                    
                  },
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.greenAccent, width: 1)),
                  ),
                  
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Container(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ForgotScreen()));
                  },
                  child: Text(
                    "Forgot password ?",
                    style: TextStyle(color: Colors.greenAccent),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Future<bool> check = logIn();
                      // ignore: unrelated_type_equality_checks
                      if (check == true) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    AboutScreen()));
                      }
                      
                      //logIn();
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.greenAccent,
                  child: Text(
                    "Log In",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  padding: EdgeInsets.all(10),
                )),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.blue,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: RaisedButton(
                onPressed: () {
                  _gooogleSignIn();
                  if (signInState) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => AboutScreen()));
                  }
                },
                color: Colors.white,
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.google, color: Colors.greenAccent),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Sign in with google",
                      style: TextStyle(fontSize: 20, color: Color(0xff000725)),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
                child: Column(
              children: <Widget>[
                Text(
                  "Don't have an account ?",
                  style: TextStyle(color: Colors.white),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => SignUpScreen()));
                    },
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.blue),
                        ),
                        Container(
                          width: 45,
                          height: 1,
                          color: Colors.blue,
                        ),
                      ],
                    ))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
