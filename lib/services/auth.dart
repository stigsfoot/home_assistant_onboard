import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../providers/mainProvider.dart';
//import './services.dart';
import 'dart:async';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  // Variable for the is onboarding complete or not.
  bool isOnboardingComplete;

  // Variable for selected Assets
  List selectedAssets = [];
  List selectedInstalledDate;
  List selectedRemindingDate;
  List selectedAssetsType = [];

  // Firebase user one-time fetch
  Future<FirebaseUser> get getUser => _auth.currentUser();

  Firestore get getDB => _db;

  // Firebase user a realtime stream
  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  // Get is onboarding Complete for this user or not.
  bool get isCompetedOnboarding => isOnboardingComplete;

  // Set onboarding complete locally
  void setOnboardingCompleteLocally(String assetText, String assetType,
      DateTime installedDate, DateTime reminderDate,
      {BuildContext ctx}) {
    isOnboardingComplete = true;
    // Also set the global variables here in Provider
    // Access the main Provider
    final providerData = Provider.of<MainProvider>(ctx, listen: false);

    // Set provider Data
    // Bug coming up here, previous selected Assets are not being deleted locally
    // Work aroud
    // TODO: Fix this when adding support for multiple Assets
    providerData.selectedAssets = [assetText];
    providerData.selectedInstalledDate = [installedDate];
    providerData.selectedRemindingDate = [reminderDate];
    providerData.selectedAssetType = [assetType];
    providerData.isOnboardingComplete = true;

    // TODO: Aslo fix it here
    this.selectedAssets = [assetText];
    this.selectedInstalledDate = [installedDate];
    this.selectedRemindingDate = [reminderDate];
    this.selectedAssetsType = [assetType];
  }

  // Set onboarding complete in users Collection for when the user completes the onboarding
  // And also upload selected data to Firebase
  Future<void> setOnboardingComplete(
    String selectedAssetText,
    String selectedAssetType,
    DateTime selectedInstalledDate,
    DateTime selectedReminderDate,
  ) async {
    FirebaseUser user = await getUser;
    print('Setting onboarding complete with type: $selectedAssetType');
    await _db.collection('users').document(user.uid).setData(
      {
        'uid': user.uid,
        'isOnboardingCompleted': true,
        'selectedAssets': [selectedAssetText],
        'type': [selectedAssetType],
        'installedDate': [selectedInstalledDate],
        'remindingDate': [selectedReminderDate],
      },
    );
  }

  /// Sign in with Google
  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser user = result.user;

      // Update user data
      // FIXED THIS:
      // You didn't add Rule for the write,read for the report collection.
      // that's why the report collection wasn't created.
      // I added the Rule to fix it.
      updateUserData(user);
      await createUser(user);

      return user;
      // TODO: better error handling
    } catch (error) {
      print(error);
      return null;
    }
  }

  /// Anonymous Firebase login
  Future<FirebaseUser> anonLogin() async {
    AuthResult result = await _auth.signInAnonymously();
    FirebaseUser user = result.user;

    updateUserData(user);
    // TODO: Also handle createUser Func, and onBoarding here.
    return user;
  }

  // Create User data in Users Collection
  Future<void> createUser(FirebaseUser user) async {
    // Check if user exists by checking if the UID collection exists.
    DocumentSnapshot ds =
        await _db.collection('users').document(user.uid).get();
    bool doesUserAlreadyExist = ds.exists;
    if (!doesUserAlreadyExist) {
      print('Creating New User');
      await _db.collection('users').document(user.uid).setData(
        {
          'uid': user.uid,
          'isOnboardingCompleted': false,
        },
      );
      isOnboardingComplete = false;
    } else {
      // user Already Exists.
      // Check if onboarding is complete or not.
      print('User Already Exists !');
      isOnboardingComplete = ds.data['isOnboardingCompleted'];
      print('User onboarding Status: $isOnboardingComplete');
      if (isOnboardingComplete) {
        print('ASSET LIST HERE');
        print(ds.data['selectedAssets']);
        print('Data Here !');
        print(ds.data);
        selectedAssets = ds.data['selectedAssets'];
        List tempRemindingList = [];

        ds.data['remindingDate'].forEach(
          (element) {
            tempRemindingList.add(
              DateTime.fromMillisecondsSinceEpoch(
                  element.millisecondsSinceEpoch),
            );
          },
        );
        List tempInstalledList = [];
        ds.data['installedDate'].forEach(
          (element) {
            tempInstalledList.add(
              DateTime.fromMillisecondsSinceEpoch(
                  element.millisecondsSinceEpoch),
            );
          },
        );
        print('DATE LIST HERE:');
        print(tempInstalledList);
        print(tempRemindingList);
        this.selectedInstalledDate = tempInstalledList;
        this.selectedRemindingDate = tempRemindingList;
        this.selectedAssetsType = ds.data['type'];
      }
    }
  }

  /// Updates the User's data in Firestore on each new login
  Future<void> updateUserData(FirebaseUser user) async {
    DocumentReference reportRef = _db.collection('reports').document(user.uid);

    await reportRef.setData(
      {'uid': user.uid, 'lastActivity': DateTime.now()},
      merge: true,
    );
  }

  // Sign out
  Future<void> signOut() {
    return _auth.signOut();
  }

  // Delete User
  Future<void> deleteUser() async {
    FirebaseUser user = await getUser;
    try {
      await user.delete();
    } catch (e) {
      print('Error Deleting User!');
      print(e.toString());
      throw e;
    }
  }
}
