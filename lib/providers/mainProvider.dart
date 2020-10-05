import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainProvider with ChangeNotifier {
  List selectedAssets = [];
  List selectedAssetType = [];
  List selectedInstalledDate;
  List selectedRemindingDate;
  bool isOnboardingComplete;
  AuthService auth = AuthService();

  void editAsset({
    @required int index,
    @required String newAssetName,
    @required DateTime newAssetInstallDate,
    @required DateTime newAssetRemindingDate,
  }) {
    this.selectedAssets[index] = newAssetName;
    this.selectedInstalledDate[index] = newAssetInstallDate;
    this.selectedRemindingDate[index] = newAssetRemindingDate;

    _updateAssetFirebase();
  }

  void addAsset(
      {@required String selectedAssetText,
      @required String assetType,
      @required DateTime installedDate,
      @required DateTime reminderDate}) {
    selectedAssets.add(selectedAssetText);
    selectedInstalledDate.add(installedDate);
    selectedRemindingDate.add(reminderDate);
    selectedAssetType.add(assetType);
    _updateAssetFirebase();
  }

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
      },
    );
  }
}
