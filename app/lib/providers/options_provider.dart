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

  set type(Types t) {
    prefs?.setInt('type', t.index);
    notifyListeners();
  }

  Dimensions get dimension {
    return Dimensions.values[prefs?.getInt('dimension') ?? Dimensions.a4.index];
  }

  set dimension(Dimensions d) {
    prefs?.setInt('dimension', d.index);
    notifyListeners();
  }

  Resolutions get resolution {
    return Resolutions
        .values[prefs?.getInt('resolution') ?? Resolutions.text.index];
  }

  set resolution(Resolutions r) {
    prefs?.setInt('resolution', r.index);
    notifyListeners();
  }

  ColorPreferences get color {
    return ColorPreferences
        .values[prefs?.getInt('color') ?? ColorPreferences.color.index];
  }

  set color(ColorPreferences c) {
    prefs?.setInt('color', c.index);
    notifyListeners();
  }

  double get quality {
    return prefs?.getDouble('quality') ?? 80;
  }

  set quality(double q) {
    prefs?.setDouble('quality', q);
    notifyListeners();
  }
}
