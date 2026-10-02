import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  bool _isAdmin = false;
  String _adminPin = '123456'; // Default PIN Admin Cikang Outdoor

  bool get isAdmin => _isAdmin;

  bool login(String inputPin) {
    if (inputPin.trim() == _adminPin) {
      _isAdmin = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAdmin = false;
    notifyListeners();
  }

  void changePin(String newPin) {
    if (newPin.trim().length >= 4) {
      _adminPin = newPin.trim();
      notifyListeners();
    }
  }
}
