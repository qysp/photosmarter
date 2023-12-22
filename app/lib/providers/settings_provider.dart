import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? prefs;

  SettingsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  String get baseUrl {
    return prefs?.getString('baseUrl') ?? '';
  }

  set baseUrl(String url) {
    prefs?.setString('baseUrl', url);
    notifyListeners();
  }
}
