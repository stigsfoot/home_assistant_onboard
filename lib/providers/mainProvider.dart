import 'package:flutter/material.dart';
import '../services/services.dart';

// TODO: Document
class MainProvider with ChangeNotifier {
  List selectedAssets = [];
  DateTime selectedInstalledDate;
  DateTime selectedRemindingDate;
  bool isOnboardingComplete;
  AuthService auth = AuthService();
}
