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

enum Color {
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

  Color get color {
    return Color.values[prefs?.getInt('color') ?? Color.color.index];
  }

  set color(Color c) {
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
