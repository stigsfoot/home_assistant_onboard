import 'package:flutter/material.dart';
import '../services/services.dart';
import 'package:intl/intl.dart';

class OnboardingDateScreen extends StatefulWidget {
  OnboardingDateScreen({
    Key key,
    @required this.selectedAsset,
    @required this.selectedAssetText,
  }) : super(key: key);

  // The Selected Asset as an Enum
  final selectedAsset;
  // The Selected Asset in String form to display to User
  final selectedAssetText;

  @override
  _OnboardingDateScreenState createState() => _OnboardingDateScreenState();
}

class _OnboardingDateScreenState extends State<OnboardingDateScreen> {
  bool hasSelectedInstalledDate = false;
  DateTime installedDate;

  bool hasSelectedRemindedDate = false;
  DateTime remindedDate;
  final AuthService auth = AuthService();

  nextScreen(BuildContext ctx) {
    if (!hasSelectedInstalledDate || !hasSelectedRemindedDate) {
      Scaffold.of(ctx).removeCurrentSnackBar();
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please Select ${!hasSelectedInstalledDate ? 'installed date' : 'reminding date'}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(
            seconds: 2,
          ),
        ),
      );
    } else {
      // All dates have been selected, go to next dashboard screen
      print('All Good !');

      /// TODO: If you want to send any of the data selected to firebase,
      /// Do it here

      // Set onboarding as completed Locally
      auth.setOnboardingCompleteLocally();
      // Set onboarding as completed in user Collection
      auth.setOnboardingComplete();
      // Navigate to the onboarding Screen again, which will detect
      // that onboardingComplete variable is now true
      // And it will render the home dashboard Screen
      Navigator.of(ctx).popAndPushNamed('/onboarding');
    }
  }

  Future<void> pickInstalledDate(BuildContext ctx) async {
    DateTime pickedDate = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        hasSelectedInstalledDate = true;
        installedDate = pickedDate;
      });
    } else {
      // It is null, user cancelled date picking
      print('User Cancelled Date Picking');
    }
  }

  Future<void> pickRemindedDate(BuildContext ctx) async {
    DateTime pickedDate = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      setState(() {
        hasSelectedRemindedDate = true;
        remindedDate = pickedDate;
      });
    } else {
      // It is null, user cancelled date picking
      print('User Cancelled Date Picking');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget returnSelectedAssetIcon() {
      if (widget.selectedAsset == Assets.HVAC) {
        return Icon(
          Icons.hvac,
          size: 23,
        );
      } else if (widget.selectedAsset == Assets.Add) {
        return Icon(
          Icons.power,
          size: 23,
        );
      } else if (widget.selectedAsset == Assets.Appliance) {
        return Icon(
          Icons.kitchen,
          size: 23,
        );
      } else if (widget.selectedAsset == Assets.Plumbing) {
        return Icon(
          Icons.plumbing,
          size: 23,
        );
      } else {
        return Icon(
          Icons.roofing,
          size: 23,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Add home asset'),
      ),
      body: Builder(
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  returnSelectedAssetIcon(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      '${widget.selectedAssetText} selected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Installed: ${hasSelectedInstalledDate ? DateFormat('d/M/y').format(installedDate).toString() : ''}',
                    style: TextStyle(
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FlatButton(
                      onPressed: () {
                        pickInstalledDate(context);
                      },
                      color: Colors.lightBlueAccent[700],
                      child: Text(
                        'Select Date',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 40),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date to be reminded: ${hasSelectedRemindedDate ? DateFormat('d/M/y').format(remindedDate).toString() : ''}',
                    style: TextStyle(
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FlatButton(
                      onPressed: () {
                        pickRemindedDate(context);
                      },
                      color: Colors.lightBlueAccent[700],
                      child: Text(
                        'Select Date',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 150),
            Center(
              child: FlatButton(
                child: Container(
                  width: 60,
                  height: 40,
                  child: Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  nextScreen(ctx);
                },
                color: Colors.lightBlueAccent[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
