import 'package:flutter/material.dart';

class ActivateBn with ChangeNotifier {
  bool _activateBn = true;

  bool get bnStatus => _activateBn;

  void changeActiveBnStatus(bool activeBn) {
    _activateBn = activeBn;
    notifyListeners();
  }
}
