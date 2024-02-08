
import 'dart:io';

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