import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainProvider with ChangeNotifier {
  List selectedAssets = [];
  List selectedInstalledDate;
  List selectedRemindingDate;
  bool isOnboardingComplete;
  AuthService auth = AuthService();

  void addAsset(
      {@required String selectedAssetText,
      @required DateTime installedDate,
      @required DateTime reminderDate}) {
    selectedAssets.add(selectedAssetText);
    selectedInstalledDate.add(installedDate);
    selectedRemindingDate.add(reminderDate);
    _addAssetFirebase();
  }

  Future<void> _addAssetFirebase() async {
    Firestore db = auth.getDB;
    FirebaseUser user = await auth.getUser;

    await db.collection('users').document(user.uid).setData(
      {
        'uid': user.uid,
        'isOnboardingCompleted': true,
        'selectedAssets': selectedAssets,
        'installedDate': selectedInstalledDate,
        'remindingDate': selectedRemindingDate,
      },
    );
  }
}
