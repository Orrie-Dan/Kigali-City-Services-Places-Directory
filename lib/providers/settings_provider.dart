import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _locationNotificationsKey =
      'location_notifications_enabled';

  bool isLoading = false;
  String? errorMessage;

  bool _locationNotificationsEnabled = false;

  bool get locationNotificationsEnabled => _locationNotificationsEnabled;

  Future<void> loadPreferences() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _locationNotificationsEnabled =
          prefs.getBool(_locationNotificationsKey) ?? false;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLocationNotificationsEnabled(bool enabled) async {
    _locationNotificationsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_locationNotificationsKey, enabled);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

