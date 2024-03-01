
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img_tool;
import 'package:path_provider/path_provider.dart';

double getDiaryWidth(BuildContext context){
  var size = MediaQuery.of(context).size;
  var aspectRatio = size.aspectRatio; //세로/가로
  if(aspectRatio >= 3/2) return size.width/2;
  return size.width;
}

DateFormat getDayFormat(BuildContext context){
  return DateFormat("Date Format".tr(),context.locale.languageCode);
}

void saveOther(String other_path,String MediaPath,String fileName) async{
  XFile other = XFile(other_path);
  String path = "${MediaPath}/${fileName}";
  Directory dir = Directory(MediaPath);
  dir.create();
  other.saveTo(path);
}

void saveImage(String image_path,String MediaPath,String fileName) async{

  XFile image = XFile(image_path);
  var media = await img_tool.decodeImageFile(image.path);
  var jpg = img_tool.encodeJpg(media!,quality: 75);

  String path = "${MediaPath}/${fileName}";
  Directory dir = Directory(MediaPath);
  dir.create();

  await File(path).writeAsBytes(jpg);

}

Future<String> getMediaDir() async{
  Directory doc;
  if(Platform.isAndroid){
    doc = await getApplicationSupportDirectory();
  }
  else{
    doc = await Directory.current;
  }
  return doc.path+"/Media";
}