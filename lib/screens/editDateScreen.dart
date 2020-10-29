import 'dart:math';
import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';

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

  final picker = ImagePicker();
  bool hasPickedImage = false;
  List pickedFiles = [];
  List pickedFileTypes = [];
  File pickedImage;
  String selectedSource;
  bool isUploading = false;

  String currDownloadingID;

  List fileRenderRow = <Widget>[];

  Widget showAlertDialog(BuildContext ctx) {
    Widget confirmButton = FlatButton(
      child: Text(
        'Ok',
      ),
      onPressed: () {
        Navigator.of(ctx).pop();
      },
    );
    return AlertDialog(
      title: Text('Remove previous files'),
      content: Text(
        'You are limited to 5 files in this version. Remove previous files to upload more.',
      ),
      actions: [
        confirmButton,
      ],
    );
  }

  Future<void> pickImageCamera() async {
    if (fileRenderRow.length >= 5) {
      showDialog(
        context: context,
        builder: (ctx) {
          return showAlertDialog(ctx);
        },
      );
      return;
    }

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
          pickedFiles.add(file);
          pickedFileTypes.add('Camera');
          selectedSource = 'Camera';
          print('Image Selected from Camera!');
        },
      );
    } else {
      print('No image selected...');
    }
  }

  Future<void> pickImageGallery() async {
    if (fileRenderRow.length >= 5) {
      showDialog(
        context: context,
        builder: (ctx) {
          return showAlertDialog(ctx);
        },
      );
      return;
    }

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
          pickedFiles.add(file);
          pickedFileTypes.add('Gallery');
          selectedSource = 'Gallery';
          print('Image Selected from Gallery!');
        },
      );
    } else {
      print('No image selected...');
    }
  }

  Future<void> pickFile() async {
    if (fileRenderRow.length >= 5) {
      showDialog(
        context: context,
        builder: (ctx) {
          return showAlertDialog(ctx);
        },
      );
      return;
    }

    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: [
        'pdf',
        // 'doc',
      ],
    );

    if (result != null) {
      setState(
        () {
          File file = File(result.files.single.path);
          hasPickedImage = true;
          pickedImage = file;
          pickedFiles.add(file);
          pickedFileTypes.add('File Manager');
          selectedSource = 'File Manager';
          print('File Selected from File Manager!');
        },
      );
    } else {
      print('No file Selected...');
    }
  }

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

      if (hasPickedImage) {
        setState(
          () {
            isUploading = true;
            showUploading(ctx);
          },
        );
        int uploadCount = 0;
        pickedFiles.asMap().forEach(
          (int index, file) async {
            final fileName = file.path.split('/').last;
            final fileType = fileName.split('.').last;
            final String currTime = DateTime.now().toString();
            final newFileName = fileName + '--' + currTime + '.' + fileType;
            final pickedFile = await file.rename(
              file.path.replaceFirst(fileName, newFileName),
            );
            print('OLD FILE NAME:');
            print(fileName);
            print('NEW FILE NAME:');
            print(newFileName);
            print('Uploading image file...');
            print('Path:');
            print(pickedFile.path);
            print('File Name:');
            print(newFileName);
            final result = await providerData.uploadMultiFiles(
              pickedFile,
              {
                'fileName': newFileName,
                'time': currTime,
                'source': pickedFileTypes[index],
                'path': pickedFile.path,
              },
              widget.index,
            );
            if (!result) {
              setState(
                () {
                  isUploading = false;
                  Navigator.of(ctx).pop();
                },
              );
              // if (providerData.uploadedFileNames.last['data'] != [] &&
              //     providerData.uploadedFileNames.last['data'] != null) {
              //   providerData.uploadedFileNames.last['data'].forEach(
              //     (fileName) {
              //       providerData.removeFile(fileName);
              //     },
              //   );
              // }
              // providerData.uploadedFileNames.removeLast();
              // providerData.downloadURLs.removeLast();

              showDialog(
                context: ctx,
                builder: (ctx) => AlertDialog(
                  title: Text('Failed to upload'),
                  content: Text(
                      'Failed to upload files, please check your internet connection and try again.'),
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
              uploadCount++;
              print(uploadCount);
              print(pickedFiles.length);
              if (uploadCount == pickedFiles.length) {
                print('Uploaded All !');
                setState(
                  () {
                    isUploading = false;
                    Navigator.of(ctx).pop();
                  },
                );

                providerData.editAsset(
                  newAssetName: newName,
                  index: widget.index,
                  newAssetInstallDate: this.installedDate,
                  newAssetRemindingDate: this.remindedDate,
                  uploadedImages: true,
                );
                // Navigate to the onboarding Screen again, which will detect
                // that onboardingComplete variable is true
                // And it will render the home dashboard Screen
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pushReplacementNamed('/onboarding');
              }
            }
          },
        );
      } else {
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context, listen: false);
    final AuthService auth = providerData.auth;

    List uploadedImageName;
    List uploadedImageURL;
    bool hasImages;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    fileRenderRow = <Widget>[];

    try {
      uploadedImageName = providerData.uploadedFileNames[widget.index]['data'];
      uploadedImageURL = providerData.downloadURLs[widget.index]['data'];
      print('Uploaded File Names:');
      print(uploadedImageName);
      print('Uploaded Download Links:');
      print(uploadedImageURL);
      hasImages = true;
    } catch (e) {
      print('No Image uploaded for this Asset...');
      hasImages = false;
    }

    if (hasImages) {
      uploadedImageURL.asMap().forEach(
        (index, element) {
          String type = (element as String)
              .split('?alt=')[0]
              .split('.')
              .last
              .toLowerCase();

          if (type == 'pdf') {
            type = 'File Manager';
          } else {
            type = 'Picture';
          }
          fileRenderRow.add(
            returnNetworkImageThumbnailPreview(
              element,
              index,
              type,
              uploadedImageName[index],
            ),
          );
        },
      );
    }

    pickedFiles.asMap().forEach(
      (index, element) {
        fileRenderRow.add(
          returnImageThumbnailPreview(element, index, pickedFileTypes[index]),
        );
      },
    );
    print(
        "''''''''''''''''''''''''''''''''''''''RERENDER''''''''''''''''''''''''''''''");
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
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              nextScreen(context, auth);
            },
          )
        ],
      ),
      body: Builder(
        builder: (ctx) => Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height -
                    statusBarHeight -
                    AppBar().preferredSize.height -
                    144,
                child: SingleChildScrollView(
                  child: Column(
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
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      fileRenderRow.length > 0
                          ? Container(
                              height: 210,
                              width: width,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: fileRenderRow,
                              ),
                            )
                          : Container(),
                      // SizedBox(height: 150),
                      // Center(
                      //   child: FlatButton(
                      //     child: Container(
                      //       width: 60,
                      //       height: 40,
                      //       child: Center(
                      //         child: Text(
                      //           'OK',
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 16,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     onPressed: () {
                      //       nextScreen(ctx, auth);
                      //     },
                      //     color: Colors.lightBlueAccent[700],
                      //   ),
                      // ),
                      // Expanded(
                      //   child: Container(),
                      // ),
                    ],
                  ),
                ),
              ),
              bottomFileSelector(width),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget returnImageThumbnailPreview(File imageFile, int index, String type) {
    return Stack(
      children: [
        Container(
          width: 200,
          height: 200,
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: imageFile != null
                ? type != 'File Manager'
                    ? Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 34,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'PDF File',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                : Container(),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          width: 30,
          height: 30,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.1, sigmaY: 2.1),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
              ),
              Positioned(
                top: -4.5,
                left: -4.5,
                child: Container(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: IconButton(
                      splashRadius: 1,
                      onPressed: () {
                        setState(
                          () {
                            print('Removing File...');
                            pickedFiles.removeAt(index);
                            pickedFileTypes.removeAt(index);
                            if (pickedFiles.isEmpty) {
                              print('Setting Picked any file to false...');
                              hasPickedImage = false;
                            }
                          },
                        );
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget returnNetworkImageThumbnailPreview(
    String fileURL,
    int index,
    String type,
    String fileName,
  ) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // TODO: Handle Here !
            print('Tappppppp!');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HeroPhotoViewRouteWrapper(
                  imageProvider: NetworkImage(
                    fileURL,
                  ),
                  tag: fileURL,
                ),
              ),
            );
          },
          child: Hero(
            tag: fileURL,
            child: Container(
              width: 200,
              height: 200,
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    type != 'File Manager'
                        ? Container(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(),
                    fileURL != null
                        ? type != 'File Manager'
                            ? Container(
                                width: 200,
                                height: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    fileURL,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf,
                                        size: 34,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'PDF File',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          width: 30,
          height: 30,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.1, sigmaY: 2.1),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
              ),
              Positioned(
                top: -4.5,
                left: -4.5,
                child: Container(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: IconButton(
                      splashRadius: 1,
                      onPressed: () {
                        setState(
                          () {
                            print('Removing File...');
                            final providerData = Provider.of<MainProvider>(
                                context,
                                listen: false);
                            providerData.downloadURLs[widget.index]['data']
                                .removeAt(index);
                            providerData.uploadedFileNames[widget.index]['data']
                                .removeAt(index);
                            providerData.removeFile(fileName);
                            providerData.updateFirebase();
                            // pickedFileTypes.removeAt(index);
                            // if (pickedFiles.isEmpty) {
                            //   print('Setting Picked any file to false...');
                            //   hasPickedImage = false;
                            // }
                          },
                        );
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Container bottomFileSelector(double width) {
    return Container(
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
    );
  }
}

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    this.imageProvider,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.tag,
  });

  final ImageProvider imageProvider;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<MainProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                right: 10,
              ),
              width: double.infinity,
              height: 60,
              // color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      splashRadius: 30,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.download_rounded),
                    splashRadius: 30,
                    onPressed: () async {
                      String type =
                          tag.split('?alt=')[0].split('.').last.toLowerCase();
                      if (type != 'pdf') {
                        providerData.donwloadFile(
                          tag,
                          'Image Asset ${DateTime.now().toString()}.$type',
                          false,
                        );
                      } else {
                        providerData.donwloadFile(
                          tag,
                          'PDF Asset ${DateTime.now().toString()}.$type',
                          true,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  (60 + MediaQuery.of(context).padding.top),
              child: PhotoView(
                imageProvider: imageProvider,
                backgroundDecoration: backgroundDecoration,
                minScale: minScale,
                maxScale: maxScale,
                heroAttributes: PhotoViewHeroAttributes(tag: tag),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
