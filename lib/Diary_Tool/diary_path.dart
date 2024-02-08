
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Diary_Path{
  Future<String> getGalleryPath() async{
    Directory doc;
    if(Platform.isAndroid){
      doc = await getApplicationSupportDirectory();
    }
    else{
      doc = await Directory.current;
    }
    return doc.path+"/Gallery";
  }
}