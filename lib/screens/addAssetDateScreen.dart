import 'dart:math';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/services.dart';
import '../providers/mainProvider.dart';

class AddAssetDateScreen extends StatefulWidget {
  AddAssetDateScreen(
      {Key key, @required this.selectedAsset, @required this.selectedAssetText})
      : super(key: key);

  // The Selected Asset as an Enum
  final selectedAsset;
  // The Selected Asset in String form to display to User
  final selectedAssetText;
  @override
  _AddAssetDateScreenState createState() => _AddAssetDateScreenState();
}

class _AddAssetDateScreenState extends State<AddAssetDateScreen> {
  bool hasSelectedInstalledDate = false;
  DateTime installedDate;

  bool hasSelectedRemindedDate = false;
  DateTime remindedDate;

  TextEditingController textController = TextEditingController();

  final picker = ImagePicker();
  bool hasPickedImage = false;
  File pickedImage;
  String selectedSource;
  bool isUploading = false;

  Future<void> pickImageCamera() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(
        () {
          final File file = File(pickedFile.path);
          hasPickedImage = true;
          pickedImage = file;
          selectedSource = 'Camera';
          print('Image Selected from Camera!');
        },
      );
    } else {
      print('No image selected...');
    }
  }

  Future<void> pickImageGallery() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(
        () {
          final File file = File(pickedFile.path);
          hasPickedImage = true;
          pickedImage = file;
          selectedSource = 'Gallery';
          print('Image Selected from Gallery!');
        },
      );
    } else {
      print('No image selected...');
    }
  }

  Future<void> pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: [
        'pdf',
        'doc',
      ],
    );

    if (result != null) {
      setState(
        () {
          File file = File(result.files.single.path);
          hasPickedImage = true;
          pickedImage = file;
          selectedSource = 'File Manager';
          print('File Selected from File Manager!');
        },
      );
    } else {
      print('No file Selected...');
    }
  }

  Future<void> nextScreen(BuildContext ctx, AuthService auth) async {
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
      // Set onboarding as completed Locally
      print('Selected Name:');
      String newName = textController.value.text.trim();
      print(newName);

      if (newName != '') {
        print('Name is OK!');
      } else {
        print('Retaining the original Asset name, nothing has been entered...');
        newName = widget.selectedAssetText;
        print(newName);
        // newName = '';
      }

      // Set onboarding as completed in user Collection
      // Aslo pass in the data to be uplaoded to Firebase
      final providerData = Provider.of<MainProvider>(ctx, listen: false);
      providerData.addAsset(
        selectedAssetText: newName,
        assetType: widget.selectedAssetText,
        installedDate: this.installedDate,
        reminderDate: this.remindedDate,
      );
      // Check if Image has been selected
      if (hasPickedImage) {
        // Upload the Image:
        final fileName = pickedImage.path.split('/').last;
        final fileType = fileName.split('.').last;
        final String currTime = DateTime.now().toString();
        final newFileName = fileName + '--' + currTime + '.' + fileType;
        pickedImage = await pickedImage.rename(
          pickedImage.path.replaceFirst(fileName, newFileName),
        );
        print('OLD FILE NAME:');
        print(fileName);
        print('NEW FILE NAME:');
        print(newFileName);
        print('Uploading image file...');
        print('Path:');
        print(pickedImage.path);
        print('File Name:');
        print(newFileName);
        // Show Loading Progress bar:
        setState(
          () {
            isUploading = true;
            showUploading(ctx);
          },
        );
        final result = await providerData.uploadFile(
          pickedImage,
          {
            'fileName': newFileName,
            'time': currTime,
            'source': selectedSource,
            'path': pickedImage.path,
          },
        );
        setState(
          () {
            isUploading = false;
            Navigator.of(ctx).pop();
          },
        );

        if (!result) {
          showDialog(
            context: ctx,
            builder: (ctx) => AlertDialog(
              title: Text('Failed to upload'),
              content: Text(
                  'Failed to upload image, please check your internet connection and try again.'),
              actions: [
                FlatButton(
                  child: Text(
                    'Ok',
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        } else {
          Navigator.of(ctx).pop();
          Navigator.of(ctx).pushReplacementNamed('/onboarding');
        }
      } else {
        // Navigate to the onboarding Screen again, which will detect
        // that onboardingComplete variable is true
        // And it will render the home dashboard Screen
        providerData.downloadURLs.add(null);
          providerData.uploadedFileNames.add(null);
        Navigator.of(ctx).pop();
        Navigator.of(ctx).pushReplacementNamed('/onboarding');
      }
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

  void showUploading(BuildContext ctx) {
    showGeneralDialog(
      context: ctx,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        title: Text(
          'Uploading...',
          textAlign: TextAlign.center,
        ),
        content: Container(
          height: 0.15 * MediaQuery.of(context).size.height,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        elevation: 2,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4 * anim1.value,
          sigmaY: 4 * anim1.value,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context, listen: false);
    final AuthService auth = providerData.auth;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
        title: Text('Add Home Asset'),
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
                      'Add ${widget.selectedAssetText}',
                      style: TextStyle(
                        fontSize: 30,
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
                  labelText: 'Personalize ${widget.selectedAssetText} Asset',
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
                      // color: Colors.lightBlueAccent[700],
                      child: Icon(
                        Icons.today,
                        size: 50,
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
                      fontSize: 20,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FlatButton(
                      onPressed: () {
                        pickRemindedDate(context);
                      },
                      //color: Colors.lightBlueAccent[700],
                      child: Icon(
                        Icons.today,
                        size: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.only(left: 20, top: 40),
              child: FlatButton(
                child: Container(
                  width: 120,
                  height: 60,
                  child: Center(
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  nextScreen(ctx, auth);
                },
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: selectedSource == null
                  ? Text('No file Selected')
                  : selectedSource == 'File Manager'
                      ? Text('File selected from File Manager')
                      : Text('Image Selected from $selectedSource'),
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              width: double.infinity,
              color: Color(0xFF424242),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    splashRadius: 1,
                    icon: Icon(
                      Icons.camera_alt,
                      size: 30,
                    ),
                    onPressed: () {
                      pickImageCamera();
                    },
                  ),
                  IconButton(
                    splashRadius: 1,
                    icon: Icon(
                      Icons.image,
                      size: 30,
                    ),
                    onPressed: () {
                      pickImageGallery();
                    },
                  ),
                  SizedBox(
                    width: width * 0.45,
                  ),
                  Transform.rotate(
                    angle: 25 * pi / 180,
                    child: IconButton(
                      splashRadius: 1,
                      icon: Icon(
                        Icons.attach_file,
                        size: 30,
                      ),
                      onPressed: () {
                        // print('Pressed !');
                        pickFile();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
