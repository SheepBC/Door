
import 'dart:convert';
import 'dart:io';

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