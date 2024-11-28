import 'package:flutter/material.dart';
import 'package:photosmarter/models/server_settings.dart';
import 'package:photosmarter/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? prefs;
  ServerSettings? serverSettings;

  SettingsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();

    await _loadServerSettings();

    notifyListeners();
  }

  String get baseUrl {
    return prefs?.getString('baseUrl') ?? '';
  }

  set baseUrl(String url) {
    prefs?.setString('baseUrl', url);
    _loadServerSettings();
    notifyListeners();
  }

  bool get isDirectDownloadAllowed {
    return serverSettings?.isDirectDownloadAllowed ?? false;
  }

  Future<void> _loadServerSettings() async {
    final response = await dio.get('$baseUrl/api/settings');
    serverSettings = ServerSettings.fromJson(response.data);
  }
}
