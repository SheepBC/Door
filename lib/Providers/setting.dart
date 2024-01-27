
import 'dart:convert';

import 'package:door/Providers/theme_setting.dart';
import 'package:door/Tools/file_tool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Setting with ChangeNotifier{

  Theme_Setting theme = Theme_Setting();

  void change(){
    notifyListeners();
  }

  Setting(){

  }

  Setting.fromJson(Map<String,dynamic> json) {
    fromJson(json);
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = new Map<String,dynamic>();
    data["theme"] = theme.toJson();

    return data;
  }

  void fromJson(Map<String,dynamic> json){
    var theme_json = jsonEncode(json["theme"]);
    theme = Theme_Setting.fromJson(jsonDecode(theme_json.toString()));

    notifyListeners();
  }

  void save(Setting setting) async{
    var Dir = await getApplicationSupportDirectory();
    var path = Dir.path+"/Setting.json";
    
    var file_tool = File_Tool();

    var json = jsonEncode(setting.toJson());
    
    await file_tool.saveToFile(path,json);
  }
  
  void load() async{
    var Dir = await getApplicationSupportDirectory();
    var path = Dir.path+"/Setting.json";

    var file_tool = File_Tool();
    
    var text = await file_tool.loadFile(path);
    if(text != ""){
      var json = jsonDecode(text);

      fromJson(json);
    }
  }

}

enum font_list {
  Nanum_JungHagSaeng,
  Dovemayo,
  Font_Basic,

}