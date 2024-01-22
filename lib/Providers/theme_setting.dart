import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Theme_Setting with ChangeNotifier{

  ThemeMode mode = ThemeMode.light;
  ThemeMode get getMode => mode;

  void setMode(ThemeMode mode){
    this.mode = mode;
    notifyListeners();
  }

  ThemeData darkMode =
  ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.amber,
    brightness: Brightness.dark
  );

  ThemeData get getDarkMode => darkMode;

  ThemeData lightMode =
  ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.amber,
    brightness: Brightness.light
  );

  ThemeData get getLightMode => lightMode;

}