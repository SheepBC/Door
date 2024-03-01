
import 'dart:io';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image/image.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_media_info/flutter_media_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class File_Tool {

  Future<void> saveToFile(String fileName, String content) async {
    // 파일 경로를 생성함
    final file = File(fileName);
    // 파일에 내용을 저장함
    await file.writeAsString(content);
  }

//파일을 불러오는 함수
  Future<String> loadFile(String fileName) async {
    try {
      //파일을 불러옴
      final file = File(fileName);
      //불러온 파일의 데이터를 읽어옴
      String fileContents = await file.readAsString();
      return fileContents;
    } catch (e) {
      return '';
    }
  }

  bool isVideoFile(String filePath) {
    // 파일 경로에서 확장자 추출
    String extension = filePath.split('.').last.toLowerCase();

    // 비디오 파일 확장자 목록
    List<String> videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'mkv']; // 필요에 따라 확장자 추가

    // 비디오 파일인지 여부 확인
    return videoExtensions.contains(extension);
  }

  bool isGif(String filePath) {
    // 파일 경로에서 확장자 추출
    String extension = filePath.split('.').last.toLowerCase();

    // 비디오 파일 확장자 목록
    List<String> videoExtensions = ['gif']; // 필요에 따라 확장자 추가

    // 비디오 파일인지 여부 확인
    return videoExtensions.contains(extension);
  }

}

Future<LatLng?> getGps(String path) async{
  if(File_Tool().isVideoFile(path)){
    if(Platform.isWindows){
      final mediainfo = Mediainfo();
      mediainfo.quickLoad(path);
      final info = mediainfo.getInfo(MediaInfoStreamType.mediaInfoStreamGeneral,0, "xyz");
      //print(info);
      if(info == "()") return null;
      RegExp regex = RegExp(r'([-+]?\d*\.\d+|[-+]?\d+)');
      Iterable<Match> matches = regex.allMatches(info);
      List<String> numbers = matches.map((match) => match.group(0)!).toList();
      if(numbers.isEmpty) return null;
      return LatLng(double.parse(numbers[0]), double.parse(numbers[1]));
    }
    else if(Platform.isAndroid){
      await Permission.accessMediaLocation.request();

      final videoInfo = FlutterVideoInfo();
      var infos = await videoInfo.getVideoInfo(path);
      var info = infos!.location;

      if(info.toString() == "null") return null;
      RegExp regex = RegExp(r'([-+]?\d*\.\d+|[-+]?\d+)');
      Iterable<Match> matches = regex.allMatches(info!);
      List<String> numbers = matches.map((match) => match.group(0)!).toList();
      if(numbers.isEmpty) return null;
      return LatLng(double.parse(numbers[0]), double.parse(numbers[1]));

      //print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++@@${info!.location}");
      //+35.1972+129.2141/

    }
    return null;
  }
  else {
    var image = await decodeImageFile(path);
    //print("=================================================================================${image?.exif.gpsIfd.values.length}");
    //print("=================================================================================${image?.exif.gpsIfd.values}");
    var NS = image?.exif.gpsIfd[1].toString();
    var lat = image?.exif.gpsIfd[2].toString().replaceAll("[", "").replaceAll("]", "");
    var EW = image?.exif.gpsIfd[3].toString();
    var lng = image?.exif.gpsIfd[4].toString().replaceAll("[", "").replaceAll("]", "");
    //print("${lat}@${lng}@${NS!}@${EW}");
    if(image!.exif.gpsIfd.values.isEmpty) return null;
    var result = LatLng(toGps(lat!)*getMark(NS!), toGps(lng!)*getMark(EW!));
    if(result.latitude.toString() == "NaN") return null;
    return result;

  }

  return LatLng(10, 10);

}
int getMark(String s){
  var mark = 1;

  switch(s){
    case "S":
    case "W":
      mark = -1;
  }
  return mark;
}

double toGps(String s){
  List<String> list = s.split(",");
  double result = 0.0;
  int index = 0;
  list.forEach((element) {

    var divide = element.split("/");
    var num = double.parse(divide[0])/double.parse(divide[1]);
    switch(index){
      case 0:
        result += num;
        break;
      case 1:
        result += num/60;
        break;
      case 2:
        result += num/3600;
        break;
    }

    index++;
  });
  return result;
}

Future<String> getDay(String path) async{
  var file = File(path);
  file.statSync().modified;
  print(file.statSync().modified);
  return file.statSync().modified.toString();
}