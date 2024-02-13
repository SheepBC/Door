
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:door/Tools/file_tool.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:door/Diary_Tool/diary_data.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img_tool;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:door/Diary_Tool/diary_path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class DiaryPage extends StatefulWidget {
  DiaryPage({super.key,required this.day});
  
  DateTime day;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  
  QuillController quillController = QuillController.basic();
  var isReadOnly = true;
  Map<String,String> list = {};

  Diary_Data diary = Diary_Data(DateTime.now());

  double getWidth(BuildContext context){
    var size = MediaQuery.of(context).size;
    var aspectRatio = size.aspectRatio; //세로/가로
    if(aspectRatio >= 3/2) return size.width/2;
    return size.width;
  }

  void load() async{
    diary = Diary_Data(widget.day);
    await diary.Load();
    if(diary.content == ""){
      isReadOnly = false;
      setState(() {

      });
    }
    else {
      var json = jsonDecode(diary.content);
      quillController.document = Document.fromJson(json);

      if(quillController.document.toPlainText() == "\n"){
        isReadOnly = false;
      }

      diary.Gallery.forEach((element) {
        list[element] = element;
      });

      setState(() {

      });
    }
  }

  void save(){
    var json = jsonEncode(quillController.document.toDelta().toJson());
    diary.content = json;
    diary.save(diary);
  }

  void change(){
    setState(() {

    });
  }


  @override
  void initState() {
    super.initState();
    load();
    MediaKit.ensureInitialized();

  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: isReadOnly,
      onPopInvoked: (b) {
        save();
        context.pop();
      },

        child: Scaffold(
          body: Scaffold(
            appBar: AppBar(
              title: Text("Diary").tr(),
              actions: [
                if(isReadOnly)
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Center(child: Text("Edit",style: TextStyle(fontWeight: FontWeight.bold),softWrap: true,).tr(),),
                          height: 30,
                          onTap: () {
                            isReadOnly = false;
                            setState(() {

                            });
                          },
                        ),
                      ];
                    },
                    position: PopupMenuPosition.under,
                    constraints: BoxConstraints(
                      minWidth: 0.5,
                    ),
                    tooltip: "",
                  )
              ],
            ),

            body: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: getWidth(context),
                  margin: EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    reverse: true,
                    children: [
                      QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                            controller: quillController,
                            readOnly: isReadOnly,
                            autoFocus: !isReadOnly,
                            showCursor: !isReadOnly,
                            placeholder: "Placeholder".tr(),
                          )
                      ),

                      if(diary.Gallery.isNotEmpty)
                        Container(
                          width: getWidth(context),
                          height: getWidth(context)*2/3,
                          child: PageView.builder(
                              itemCount: diary.Gallery.length,
                              itemBuilder: (context,index) {
                                var path = diary.Gallery[index];

                                var media;

                                File file = File(list[path]!);
                                bool isNull = !file.existsSync();
                                if(isNull){
                                  Timer(Duration(seconds: 3), () {
                                    setState(() {

                                    });
                                  });
                                  media = Stack(
                                    children: [
                                      Container(decoration: BoxDecoration(color: Theme.of(context).highlightColor),),
                                      Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    ],
                                  );
                                }
                                else {
                                  if(!File_Tool().isVideoFile(path)){
                                    media = Image(image: FileImage(file),fit: BoxFit.cover);
                                  }
                                  else{
                                    final player = Player();
                                    final controller = VideoController(player);

                                    player.open(Media(list[path]!),play: false);
                                    media = Video(
                                        controller: controller,
                                        controls: null,
                                        fill: Colors.transparent,
                                        fit: BoxFit.cover
                                    );
                                  }
                                }

                                return InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,

                                  child: Container(
                                    margin: EdgeInsets.all(20),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: media
                                    ),
                                  ),
                                  onTap: () {
                                    if(isReadOnly){
                                      context.push("/mediaview",extra: path);
                                    }
                                    else{
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Wrap(
                                              children: [
                                                ListTile(
                                                  leading: Icon(Icons.delete),
                                                  title: Text("delete").tr(),
                                                  onTap: () {
                                                    diary.Gallery.removeAt(index);
                                                    list.remove(path);
                                                    File(path).delete();
                                                    context.pop();
                                                    setState(() {
                                                    });

                                                  },
                                                ),
                                                ListTile(
                                                  leading: Icon(Icons.message),
                                                  title: Text("memo").tr(),
                                                  onTap: () {

                                                  },
                                                )
                                              ],
                                            );
                                          }
                                      );
                                    }
                                  },
                                );
                              },
                            padEnds: false,
                          ),
                        ),

                      Container(
                        child: Text(
                          "${DateFormat("Date Format".tr(),context.locale.languageCode).format(diary.day)}",
                          textAlign: TextAlign.center,
                        ),
                        margin: EdgeInsets.all(10),
                      ),
                      Column(
                          children: [
                            InkWell(
                              child: Image.asset("assets/Emojis/Test_Emoji.png",height: 50,width: 50,),
                              onTap: (isReadOnly) ? null: () {
                                print("sd");
                              },
                            )
                          ]
                      ),
                    ],
                  ),
                )
            ),
            bottomNavigationBar: (isReadOnly) ? null :Row(
              children: [
                Expanded(child: ToolBar(controller: quillController,context: context,diary:diary,change: change,list: list,)),
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    isReadOnly = true;
                    save();
                    setState(() {

                    });
                  },
                )
              ],
            ),

          ),
        ),

    );
  }
}

class ToolBar extends StatefulWidget {
  ToolBar({super.key,required this.controller,required this.context,required this.diary,required this.change,required this.list});

  QuillController controller;
  BuildContext context;
  Diary_Data diary;
  Function change;
  Map<String,String> list;

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {

  var iconShape = IconButtonData(
    style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) => BeveledRectangleBorder())
    ),
  );

  void addGallery(String path){
    widget.diary.Gallery.add(path);
    widget.change();
  }

  Future<void> _galleryButton() async{
    if(Platform.isAndroid){
      await Permission.photos.request();
      await Permission.videos.request();
    }

    if(Platform.isIOS){

    }
    else{
      var image_Picker = ImagePicker();
      var medias =await image_Picker.pickMultipleMedia();
      medias.forEach((element) async{

        var msg = [element.path,await getMediaDir(),"null"];
        if(File_Tool().isVideoFile(element.path)){
          msg[2] = "${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(10000)}${element.name}";
          await compute((message) => saveOther(message[0],message[1],message[2]), msg);
        }
        else if(File_Tool().isGif(element.path)){
          msg[2] = "${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(10000)}${element.name}";
          await compute((message) => saveOther(message[0],message[1],message[2]), msg);
        }
        else {
          msg[2] = "${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(10000)}.png";
          compute((message) => saveImage(message[0],message[1],message[2]), msg);
        }
        var path = "${msg[1]}/${msg[2]}";
        widget.list[path] = element.path;
        addGallery("${msg[1]}/${msg[2]}");
      });
    }
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

  @override
  void initState() {
    MediaKit.ensureInitialized();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return QuillSimpleToolbar(
        configurations: QuillSimpleToolbarConfigurations(
          controller: widget.controller,
          toolbarIconAlignment: WrapAlignment.start,
          toolbarSize: 20,

          showBackgroundColorButton: false,
          showAlignmentButtons: false,
          showCenterAlignment: false,
          showClearFormat: false,
          showCodeBlock: false,
          showColorButton: false,
          showDirection: false,
          showDividers: false,
          showFontFamily: false,
          showFontSize: false,
          showHeaderStyle: false,
          showIndent: false,
          showInlineCode: false,
          showItalicButton: false,
          showJustifyAlignment: false,
          showLeftAlignment: false,
          showLink: false,
          showListBullets: false,
          showListCheck: false,
          showListNumbers: false,
          showQuote: false,
          showRedo: false,
          showRightAlignment: false,
          showSearchButton: false,
          showSmallButton: false,
          showStrikeThrough: false,
          showSubscript: false,
          showSuperscript: false,
          showUnderLineButton: false,
          showUndo: false,

          customButtons: [
            QuillToolbarCustomButtonOptions(
              icon: Icon(Icons.image),
              tooltip: "media".tr(),
              onPressed: () {
                _galleryButton();
              }
            ),
          ],

          buttonOptions: QuillSimpleToolbarButtonOptions(
            bold: QuillToolbarToggleStyleButtonOptions(
                tooltip: "bold".tr(),
                iconTheme: QuillIconTheme(

                  iconButtonSelectedData: iconShape,
                  iconButtonUnselectedData: iconShape,

                )
            ),
          )
        )

    );
  }
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
  var png = img_tool.encodePng(await img_tool.decodeImage(jpg)!);

  String path = "${MediaPath}/${fileName}";
  Directory dir = Directory(MediaPath);
  dir.create();

  await File(path).writeAsBytes(png);

}

