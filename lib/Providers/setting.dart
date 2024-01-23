
import 'package:door/Providers/theme_setting.dart';
import 'package:flutter/cupertino.dart';

class Setting with ChangeNotifier{

  Theme_Setting theme = Theme_Setting();

  void change(){
    notifyListeners();
  }

}

enum font_list {
  Nanum_JungHagSaeng,
  Dovemayo,
  Font_Basic,

}