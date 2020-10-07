import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/services.dart';
import '../providers/mainProvider.dart';
import './screens.dart';

class EditDateScreen extends StatefulWidget {
  EditDateScreen({
    Key key,
    @required this.selectedAsset,
    @required this.selectedAssetText,
    @required this.index,
    @required this.realName,
    this.canBeDeleted,
  }) : super(key: key);

  // The Selected Asset as an Enum
  final selectedAsset;
  // The Selected Asset in String form to display to User
  final selectedAssetText;
  // The index of the Asset selected
  final int index;
  // The real string name of the asset
  final String realName;
  final bool canBeDeleted;

  @override
  _EditDateScreenState createState() => _EditDateScreenState();
}

class _EditDateScreenState extends State<EditDateScreen> {
  bool hasSelectedInstalledDate = false;
  DateTime installedDate;

  bool hasSelectedRemindedDate = false;
  DateTime remindedDate;

  String newAssetName;

  TextEditingController textController = TextEditingController();

  nextScreen(BuildContext ctx, AuthService auth) {
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
      print('All Good!');
      print('Selected Name:');
      String newName = textController.value.text.trim();
      print(newName);

      if (newName != '') {
        print('Name is OK!');
      } else {
        print('Retaining the previous name, nothing has been entered...');
        newName = widget.realName;
        print(widget.realName);
        // newName = '';
      }
      // Set onboarding as completed Locally

      // Set onboarding as completed in user Collection
      // Aslo pass in the data to be uplaoded to Firebase
      final providerData = Provider.of<MainProvider>(ctx, listen: false);
      providerData.editAsset(
        newAssetName: newName,
        index: widget.index,
        newAssetInstallDate: this.installedDate,
        newAssetRemindingDate: this.remindedDate,
      );
      // Navigate to the onboarding Screen again, which will detect
      // that onboardingComplete variable is true
      // And it will render the home dashboard Screen
      Navigator.of(ctx).pop();
      Navigator.of(ctx).pushReplacementNamed('/onboarding');
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
  void initState() {
    super.initState();
    final providerData = Provider.of<MainProvider>(context, listen: false);
    this.newAssetName = widget.selectedAssetText;
    this.installedDate = providerData.selectedInstalledDate[widget.index];
    this.remindedDate = providerData.selectedRemindingDate[widget.index];
    this.hasSelectedInstalledDate = true;
    this.hasSelectedRemindedDate = true;
  }

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context, listen: false);
    final AuthService auth = providerData.auth;
    // this.newAssetName = widget.selectedAssetText;
    // this.installedDate = providerData.selectedInstalledDate[widget.index];
    // this.remindedDate = providerData.selectedRemindingDate[widget.index];
    // this.hasSelectedInstalledDate = true;
    // this.hasSelectedRemindedDate = true;
    Widget returnSelectedAssetIcon() {
      if (widget.selectedAsset == 'HVAC') {
        return Icon(
          Icons.hvac,
          size: 23,
        );
      } else if (widget.selectedAsset == 'Add' ||
          widget.selectedAsset == 'Custom') {
        return Icon(
          Icons.power,
          size: 23,
        );
      } else if (widget.selectedAsset == 'Appliance') {
        return Icon(
          Icons.kitchen,
          size: 23,
        );
      } else if (widget.selectedAsset == 'Plumbing') {
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
          providerData.deleteAsset(widget.index);
          Navigator.of(ctx).pop();
        },
      );
      return AlertDialog(
        title: Text('Are you sure ?'),
        content: Text(
            'This will delete this Asset permanently. Are you sure you want to proceed ?'),
        actions: [
          cancelButton,
          confirmButton,
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Edit Home Asset'),
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
                      '${widget.realName} selected',
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                obscureText: false,
                controller: this.textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                  labelText: 'Update Name',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Installed: ${hasSelectedInstalledDate ? DateFormat('M/d/y').format(installedDate).toString() : ''}',
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
                    'Date to be reminded: ${hasSelectedRemindedDate ? DateFormat('M/d/y').format(remindedDate).toString() : ''}',
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
                  nextScreen(ctx, auth);
                },
                color: Colors.lightBlueAccent[700],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            PrivacySettingsButton(
              text: 'Delete Asset',
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
  }
}
