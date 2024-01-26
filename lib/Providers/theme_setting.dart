import 'package:door/Providers/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Theme_Setting with ChangeNotifier{

  Theme_Setting(){

  }

  Theme_Setting.fromJson(Map<String, dynamic> json){
    mode = ThemeMode.values.firstWhere((element) => element.name == json["mode"],orElse: () => ThemeMode.light);
    setFont(font_list.values.firstWhere((element) => element.name == json["font"],orElse: () => font_list.Font_Basic));
    font_size = double.parse(json["font_size"].toString());
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["mode"] = mode.name;
    data["font"] = _font.name;
    data["font_size"] = font_size;

    return data;
  }


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

  double font_size = 1;

  double get getFont_Size => font_size;

  void setFont_Size(double size){
    font_size = size;
    notifyListeners();
  }

  MediaQuery getMediaQuery(BuildContext context,Widget widget){
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: font_size),
        child: widget
    );
  }


}