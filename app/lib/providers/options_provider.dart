import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Types {
  pdf,
  jpeg,
}

enum Dimensions {
  a4,
  letter,
}

enum Resolutions {
  high,
  text,
  photo,
  screen,
}

enum ColorPreferences {
  color,
  black,
}

class OptionsProvider extends ChangeNotifier {
  SharedPreferences? prefs;

  OptionsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  Types get type {
    return Types.values[prefs?.getInt('type') ?? Types.pdf.index];
  }

  set type(Types value) {
    prefs?.setInt('type', value.index);
    notifyListeners();
  }

  Dimensions get dimension {
    return Dimensions.values[prefs?.getInt('dimension') ?? Dimensions.a4.index];
  }

  set dimension(Dimensions value) {
    prefs?.setInt('dimension', value.index);
    notifyListeners();
  }

  Resolutions get resolution {
    return Resolutions
        .values[prefs?.getInt('resolution') ?? Resolutions.text.index];
  }

  set resolution(Resolutions value) {
    prefs?.setInt('resolution', value.index);
    notifyListeners();
  }

  ColorPreferences get color {
    return ColorPreferences
        .values[prefs?.getInt('color') ?? ColorPreferences.color.index];
  }

  set color(ColorPreferences value) {
    prefs?.setInt('color', value.index);
    notifyListeners();
  }

  double get quality {
    return prefs?.getDouble('quality') ?? 80;
  }

  set quality(double value) {
    prefs?.setDouble('quality', value);
    notifyListeners();
  }

  bool get directDownload {
    return prefs?.getBool('directDownload') ?? false;
  }

  set directDownload(bool value) {
    prefs?.setBool('directDownload', value);
    notifyListeners();
  }
}
