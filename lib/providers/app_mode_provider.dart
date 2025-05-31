import 'package:flutter/foundation.dart';
import 'package:smart_doorbell_app/models/app_mode.dart';

class AppModeProvider with ChangeNotifier {
  AppMode _currentMode = AppMode.mobile; // Defaulting to mobile

  AppMode get currentMode => _currentMode;

  void setMode(AppMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }
}
