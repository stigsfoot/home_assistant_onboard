import 'package:flutter/material.dart';
import '../services/services.dart';

class MainProvider with ChangeNotifier {
  List selectedAssets = [];
  DateTime selectedInstalledDate;
  DateTime selectedRemindingDate;
  bool isOnboardingComplete;
  AuthService auth = AuthService();
}
