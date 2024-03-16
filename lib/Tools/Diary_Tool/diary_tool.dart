
import 'dart:convert';
import 'dart:io';

import 'package:door/Tools/Diary_Tool/diary_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';

import 'diary_path.dart';

void saveMemo(String path,String memo) async{
  File file = File(await Diary_Path().getMemoPath());

  Map<String,String> memos = {};

  if(file.existsSync()){
    var read = await file.readAsString();
    print(read);
    Map<String,dynamic> json = jsonDecode(read);
    json.forEach((key, value) {
      memos[key] = value.toString();
    });
  }
  memos[path] = memo;
  var json = jsonEncode(memos);
  print("json: ${json}");

  file.writeAsString(json);
}

Future<String> getMemo(String path) async{
  File file = File(await Diary_Path().getMemoPath());

  Map<String,String> memos = {};

  if(file.existsSync()){
    var read = await file.readAsString();
    print(read);
    Map<String,dynamic> json = jsonDecode(read);
    json.forEach((key, value) {
      memos[key] = value.toString();
    });

    return memos[path].toString();
  }

  return "null";
}

bool isWrite(DateTime day,String doc){
  var path = doc+"/Diary/${DateFormat("yyyy-MM-dd").format(day)}.json";
  return File(path).existsSync();
}

Future<List<Diary_Data>> getDiaryAll() async {

  Directory doc;
  if(Platform.isAndroid){
    doc = await getApplicationSupportDirectory();
  }
  else{
    doc = await Directory.current;
  }
  List<Diary_Data> list = [];

  Directory diarys = Directory(doc.path+"/Diary");

  for (FileSystemEntity element in diarys.listSync()){
    var name = element.path.split(Platform.pathSeparator).last;
    DateTime day = DateTime.parse(name.replaceAll(".json",""));
    Diary_Data diary = Diary_Data(day);
    await diary.Load();
    list.add(diary);
  }

  return list;
}