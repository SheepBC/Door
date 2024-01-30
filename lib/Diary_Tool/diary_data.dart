
import 'dart:convert';
import 'dart:io';

import 'package:door/Tools/file_tool.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Diary_Data{

    List<Emoji> emojis = [Emoji.GOOD];

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
        print(content);
      }

    }

}

enum Emoji{
  GOOD(Icon(Icons.headphones)),
  SAD(Icon(Icons.co2)),
  NOT_BAD(Icon(Icons.cabin)),
  GOOD1(Icon(Icons.headphones)),
  SAD1(Icon(Icons.co2)),
  NOT_BAD1(Icon(Icons.cabin)),
  GOOD312(Icon(Icons.headphones)),
  SAD312(Icon(Icons.co2)),
  NOT_BAD312(Icon(Icons.cabin)),
  GOOD1321(Icon(Icons.headphones)),
  SAD1312(Icon(Icons.co2)),
  NOT_BAD1321(Icon(Icons.cabin)),
  GOOD31231(Icon(Icons.headphones)),
  SAD234(Icon(Icons.co2)),
  NOT_BAD543(Icon(Icons.cabin)),
  GOOD1413(Icon(Icons.headphones)),
  SAD1635(Icon(Icons.co2)),
  NOT_BAD1243(Icon(Icons.cabin));


  final Icon icon;
  const Emoji(this.icon);

}