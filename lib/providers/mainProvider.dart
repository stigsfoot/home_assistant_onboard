import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import '../services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// TODO: Document
class MainProvider with ChangeNotifier {
  List selectedAssets = [];
  List selectedAssetType = [];
  List selectedInstalledDate;
  List selectedRemindingDate;
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

  Future<void> setAddress() async {
    await _updateAssetFirebase();
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
      print('Nothing new entered...');
    }
  }

  List returnOrigReminderList() {
    final x = selectedRemindingDate;
    return x;
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
      },
    );
  }
}
