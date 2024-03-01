
import 'dart:convert';
import 'dart:io';

import 'package:door/Tools/Diary_Tool/diary_path.dart';
import 'package:door/Tools/file_tool.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Diary_Data{

    List<Emoji> emojis = [];
    List<String> Gallery = [];

    DateTime day = DateTime.now();

    String content = "";

    Diary_Data(DateTime day){
      this.day = day;
    }

    void save(Diary_Data diary) async{
      Directory doc;
      if(Platform.isAndroid){
        doc = await getApplicationSupportDirectory();
      }
      else{
        doc = await Directory.current;
      }

      var path = doc.path+"/Diary/${DateFormat("yyyy-MM-dd").format(day)}.json";
      var json = jsonEncode(diary.toJson());
      print(path);
      print(diary.toJson());

      Directory dir = Directory(doc.path+"/Diary");
      dir.create();

      File_Tool().saveToFile(path,json);
    }

    Map<String, dynamic> toJson(){
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data["emojis"] = getEmojisToString();
      data['day'] = day.toString();
      data['content'] = content;
      data["Gallery"] = Gallery;
      return data;
    }

    List<String> getEmojisToString(){
      List<String> list = [];
      emojis.forEach((element) {list.add(element.name);});
      return list;
    }

    Future<void> Load() async{
      Directory doc;
      if(Platform.isAndroid){
        doc = await getApplicationSupportDirectory();
      }
      else{
        doc = await Directory.current;
      }

      var path = doc.path+"/Diary/${DateFormat("yyyy-MM-dd").format(day)}.json";
      var data = await File_Tool().loadFile(path);
      if(data.isNotEmpty){
        Map<String, dynamic> json = jsonDecode(data);
        content = json["content"];
        List emojis_Slist = json["emojis"];
        Emoji.values.forEach((element) {
          bool b = emojis_Slist.contains(element.name);
          if(b) emojis.add(element);
        });
        List gallery = json["Gallery"];
        gallery.forEach((element) {
          Gallery.add(element.toString());
        });

      }

    }

}

enum Emoji{
  GOOD(Icon(Icons.headphones)),
  SAD(Icon(Icons.co2)),
  NOT_BAD(Icon(Icons.cabin));


  final Icon icon;
  const Emoji(this.icon);

}