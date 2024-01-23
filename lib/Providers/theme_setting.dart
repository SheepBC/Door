import 'package:door/Providers/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Theme_Setting with ChangeNotifier{

  ThemeMode mode = ThemeMode.light;
  ThemeMode get getMode => mode;

  void setMode(ThemeMode mode){
    this.mode = mode;
    notifyListeners();
  }

  String font = "";
  String get getFont => font;

  font_list _font = font_list.Font_Basic;
  font_list get get_Font => _font;

  void setFont(font_list font){
    this.font = font.name;
    _font = font;
    if(font == font_list.Font_Basic) this.font ="";
    notifyListeners();
  }

  ThemeData darkMode() =>
  ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.amber,
    brightness: Brightness.dark,
    fontFamily: font,
  );

  ThemeData get getDarkMode => darkMode();

  ThemeData lightMode() =>
  ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.amber,
    brightness: Brightness.light,
    fontFamily: font,
  );

  ThemeData get getLightMode => lightMode();


}