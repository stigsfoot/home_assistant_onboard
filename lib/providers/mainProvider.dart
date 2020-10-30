import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart' as paths;
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/services.dart';

// TODO: Document
class MainProvider with ChangeNotifier {
  // List for determining if user has deleted this notification in the Notifications Screen
  List hasRemovedNotif = <bool>[];
  List selectedAssets = [];
  List selectedAssetType = [];
  List selectedInstalledDate;
  List selectedRemindingDate;
  List downloadURLs = [];
  List uploadedFileNames = [];
  bool isOnboardingComplete;
  bool isNotificationsinit = false;
  AuthService auth = AuthService();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String currentTimeZone;
  // Value for Recieve Notifications Switch
  bool recieveNotifications = true;
  // User's address
  String address;
  // Reference for Firestore Storage
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  StorageReference storageRef;
  bool hasInitFirebaseStorage = false;
  bool dataConfigured = false;
  bool initDownloader = false;
  final dio = Dio();

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        final result2 = await Permission.storage.request();
        if (result == PermissionStatus.granted &&
            result2 == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<void> _showDownloadNotification(
    String songName,
    Map<String, dynamic> payload,
  ) async {
    final android = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel descriptions',
      priority: Priority.high,
      importance: Importance.max,
      icon: '@mipmap/launcher_icon',
    );
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(payload);
    final isSuccess = payload['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
      0, // Notification id ???
      isSuccess ? 'Success' : 'Failure',
      isSuccess
          ? 'Successfully Downloaded ' + songName
          : 'Failed to Download ' + songName,
      platform,
      payload: json,
    );
  }

  Future<void> donwloadFile(
    String uri,
    String fileName,
    bool isPDF,
  ) async {
    final hasPermission = await _checkPermission();
    // await _checkPermission();
    if (hasPermission) {
      final savePath = await paths.getApplicationDocumentsDirectory();
      print(savePath.path);
      String fullPath;
      if (isPDF) {
        // final downloadsPath = await DownloadsPathProvider.downloadsDirectory;
        final downloadsPath = await paths.getExternalStorageDirectory();
        fullPath = downloadsPath.path + '/' + fileName;
        // fullPath = '/storage/emulated/0/Download/' + fileName;
      } else {
        fullPath = savePath.path + '/' + fileName;
      }
      try {
        final res = await dio.download(
          uri,
          fullPath,
          deleteOnError: true,
          onReceiveProgress: (rcv, total) {
            print(
              'recieved ${rcv.toStringAsFixed(0)} out of total ${total.toStringAsFixed(0)}',
            );
            print(fullPath);

            var currProgress = ((rcv / total) * 100).toStringAsFixed(0);
            print(currProgress);
          },
        );
        // print(res.realUri);

        if (res.statusCode == 200) {
          await _showDownloadNotification(fileName, {'isSuccess': true});
          if (!isPDF) {
            await GallerySaver.saveImage(fullPath);
            print('DOWNLOADED !!!');
          } else {
            print('DONE PDF !!!');
          }
        }
      } catch (e) {
        print('ERROR DOWNLOADING....');
        await _showDownloadNotification(fileName, {'isSuccess': false});
        print(e);
        throw e;
      }
    }
  }

  // Function for initializing the Firebase Storage Reference:
  Future<void> initFirebaseStorage() async {
    if (!hasInitFirebaseStorage) {
      print('Initializing Firebase Storage...');
      FirebaseUser user = await auth.getUser;
      storageRef = firebaseStorage.ref().child('users').child(user.uid);
      print('Initialized Storage at:');
      print(storageRef.path);
      hasInitFirebaseStorage = true;
    }
  }

  // Function to upload a file to Firebase Storage:
  Future<bool> uploadFile(File file, Map<String, String> data) async {
    print('Uploading file...');
    // File name:
    if (storageRef == null || !hasInitFirebaseStorage) {
      await initFirebaseStorage();
      hasInitFirebaseStorage = true;
    }
    final ref = storageRef.child(data['fileName']);
    try {
      await ref
          .putFile(
            file,
            StorageMetadata(customMetadata: data),
          )
          .onComplete;

      // Download link for the uploaded file:
      final url = await ref.getDownloadURL();
      print('Downlaod Link for the Uploaded file:');
      print(url);
      downloadURLs.add(url);
      uploadedFileNames.add(data['fileName']);

      if (selectedAssets != []) {
        print('Updating Assets with new Uploaded File');
        _updateAssetFirebase();
      }
      return true;
    } catch (e) {
      print('ERROR: Failed to upload File...');
      print(e.toString());
      return false;
    }
  }

  // Function to upload a file to Firebase Storage:
  Future<bool> uploadMultiFiles(
    File file,
    Map<String, String> data,
    indexOfNewList,
  ) async {
    print('Uploading file...');
    // File name:
    if (storageRef == null || !hasInitFirebaseStorage) {
      await initFirebaseStorage();
      hasInitFirebaseStorage = true;
    }
    final ref = storageRef.child(data['fileName']);
    try {
      await ref
          .putFile(
            file,
            StorageMetadata(customMetadata: data),
          )
          .onComplete;

      // Download link for the uploaded file:
      final url = await ref.getDownloadURL();
      print('Download Link for the Uploaded file:');
      print(url);
      downloadURLs[indexOfNewList]['data'].add(url);
      uploadedFileNames[indexOfNewList]['data'].add(data['fileName']);

      // _updateAssetFirebase();
      // if (selectedAssets != []) {
      //   print('Updating Assets with new Uploaded File');
      // }
      return true;
    } catch (e) {
      print('ERROR: Failed to upload File...');
      print(e.toString());
      print(e);
      return false;
    }
  }

  // Function for updating data in Firebase, it is a public function.
  Future<void> updateFirebase() async {
    await _updateAssetFirebase();
  }

  // Set the Address
  // Notify Profile Screen to Re-Render
  Future<void> setAddress() async {
    notifyListeners();
    await _updateAssetFirebase();
  }

  Future<void> removeAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> changeNotificationStatus() async {
    if (!this.recieveNotifications) {
      // Remove all existing notifications, if it is set to false
      await flutterLocalNotificationsPlugin.cancelAll();
    } else {
      // Set all notifications again, as user could have selected false
      // Which would have cleared all existing notifications
      await scheduleNotifications();
    }
    await _updateAssetFirebase();
  }

  // Initialize the Flutter Notification Plugin
  Future<void> initNotifications() async {
    if (!isNotificationsinit) {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOs = IOSInitializationSettings();
      var initSetttings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOs);
      await flutterLocalNotificationsPlugin.initialize(initSetttings);
      print('Initialised Notifications!');
      isNotificationsinit = true;
    }
  }

  // Schedule all notifications
  Future<void> scheduleNotifications() async {
    // Getting current time zone
    print('Scheduling...');
    // First remove all existing Notifications:
    await flutterLocalNotificationsPlugin.cancelAll();
    if (currentTimeZone == null) {
      currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      print('Current Time Zone is null, getting again !');
    }
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    // scheduling it
    for (var i = 0; i < selectedAssets.length; i++) {
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          i,
          selectedAssets[i],
          'Service due for your ${selectedAssets[i]}',
          tz.TZDateTime.from(this.selectedRemindingDate[i], tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'your channel id',
              // Your notification channel Name (When long pressing Notification)
              'Service Reminer',
              // Your description (When long pressing Notification)
              'Service Reminder Description',
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        // Error due to date not being in future
        print('$i has date in past, not future, skiping...');
      }
    }
    print('All notifications Scheduled!');
  }

  // Schedule Notifications Test Function:
  // To activate it, goto home.dart, in the Scaffold, in the FAB,
  // Uncomment the code.
  Future<void> scheduleNotificationTest() async {
    // Getting current time zone
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    // scheduling it
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Test',
      'Test body',
      tz.TZDateTime.now(tz.local).add(
        const Duration(seconds: 5),
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          'your channel description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Function to edit existing Assets,
  // Pass in the index, the new name of the Asset,
  // the new Asset Installed Date,
  // the new Asset Reminding date,
  // And it will set the data locally, and also in Firebase
  void editAsset({
    @required int index,
    @required String newAssetName,
    @required DateTime newAssetInstallDate,
    @required DateTime newAssetRemindingDate,
    bool uploadedImages,
  }) {
    if (this.selectedAssets[index] != newAssetName ||
        this.selectedInstalledDate[index] != newAssetInstallDate ||
        this.selectedRemindingDate[index] != newAssetRemindingDate) {
      if ((this.selectedRemindingDate[index] != newAssetRemindingDate) &&
          this.recieveNotifications) {
        // schedule notification
        scheduleNotifications();
      }
      print('Updating Assets...');
      // Update data locally
      this.selectedAssets[index] = newAssetName;
      this.selectedInstalledDate[index] = newAssetInstallDate;
      this.selectedRemindingDate[index] = newAssetRemindingDate;
      // Update data in Firebase
      _updateAssetFirebase();
    } else {
      if (uploadedImages != null) {
        _updateAssetFirebase();
      } else {
        print('Nothing new entered...');
      }
    }
  }

  List returnOrigReminderList() {
    final x = selectedRemindingDate;
    return x;
  }

  Future<void> removeFile(String name) async {
    print('Deleting File with file name:');
    print(name);
    print('User Storage Path:');
    print(this.storageRef.path);
    await this.storageRef.child(name).delete();
  }

  // Function to delete existing Assets
  // Just pass in the index of the Asset,
  // The index is it's position in the List
  void deleteAsset(int index) {
    // Remove Asset locally
    this.selectedAssets.removeAt(index);
    this.selectedAssetType.removeAt(index);
    this.selectedInstalledDate.removeAt(index);
    this.selectedRemindingDate.removeAt(index);
    this.hasRemovedNotif.removeAt(index);

    try {
      final fileNamesToRemove = uploadedFileNames[index]['data'];
      (fileNamesToRemove as List).forEach(
        (file) {
          removeFile(file);
        },
      );
    } catch (e) {}

    this.downloadURLs.removeAt(index);
    this.uploadedFileNames.removeAt(index);
    // Notify home.dart to Re-render home screen
    notifyListeners();
    // Update Firebase
    _updateAssetFirebase();
    // Schedule All notifications again:
    scheduleNotifications();
  }

  // Function to add a new Asset,
  // Pass in Asset's title, type, installed date, reminding date,
  // And it will create the Asset
  void addAsset(
      {@required String selectedAssetText,
      @required String assetType,
      @required DateTime installedDate,
      @required DateTime reminderDate}) {
    // Add Asset locally
    selectedAssets.add(selectedAssetText);
    selectedInstalledDate.add(installedDate);
    selectedRemindingDate.add(reminderDate);
    selectedAssetType.add(assetType);
    hasRemovedNotif.add(false);
    // Update Firebase
    _updateAssetFirebase();
    // Schedule All notifications again:
    scheduleNotifications();
  }

  // Update Firebase, function to send the data in the list's declared above (line 12-15) to Firebase
  // User collection
  Future<void> _updateAssetFirebase() async {
    Firestore db = auth.getDB;
    FirebaseUser user = await auth.getUser;

    await db.collection('users').document(user.uid).setData(
      {
        'uid': user.uid,
        'type': selectedAssetType,
        'isOnboardingCompleted': true,
        'selectedAssets': selectedAssets,
        'installedDate': selectedInstalledDate,
        'remindingDate': selectedRemindingDate,
        'recieveNotifications': recieveNotifications,
        'address': address,
        'hasRemovedNotif': hasRemovedNotif,
        'downloadURLs': downloadURLs,
        'uploadedFileNames': uploadedFileNames,
      },
    );
  }
}
