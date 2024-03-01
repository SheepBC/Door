
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:door/Tools/DiaryPage_Tool/DiaryPage_Tool.dart';
import 'package:door/Tools/Diary_Tool/diary_data.dart';
import 'package:door/Tools/Diary_Tool/diary_tool.dart';
import 'package:door/Tools/other_tool.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Tools/file_tool.dart';

class DiaryPage extends StatefulWidget {
  DiaryPage({super.key,required this.day});

  DateTime day;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {

  Diary_Data diary_data = Diary_Data(DateTime.now());
  Map<String,String> list = {};

  ScrollController List_Controller = ScrollController();
  QuillController quillController = QuillController.basic();

  bool isReadOnly = true;

  int nowPage = 1;
  Map<String,Video> videos = {};

  void Diary_Load() async{
    diary_data = Diary_Data(widget.day);
    await diary_data.Load();

    if(diary_data.content == ""){
      isReadOnly = false;
      setState(() {

      });
    }
    else {
      var json = jsonDecode(diary_data.content);
      quillController.document = Document.fromJson(json);

      if(quillController.document.toPlainText() == "\n"){
        isReadOnly = false;
      }

      diary_data.Gallery.forEach((element) {
        list[element] = element;
      });

      setState(() {
        moveTop();
      });
    }

  }

  void save(){
    var json = jsonEncode(quillController.document.toDelta().toJson());
    diary_data.content = json;
    diary_data.save(diary_data);
  }

  void moveTop(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var max = List_Controller.position.maxScrollExtent;
      //print(max);
      List_Controller.jumpTo(max);

    });
  }

  Future<void> MediaButton() async{
    if(Platform.isAndroid){
      await Permission.photos.request();
      await Permission.videos.request();
    }

    var image_Picker = ImagePicker();
    var medias =await image_Picker.pickMultipleMedia();
    medias.forEach((element) async {
      var msg = [element.path, await getMediaDir(), "null"];
      if (File_Tool().isVideoFile(element.path)) {
        msg[2] = "${DateTime
            .now()
            .microsecondsSinceEpoch}${Random().nextInt(10000)}${element.name}";
        await compute((message) =>
            saveOther(message[0], message[1], message[2]), msg);
      }
      else if (File_Tool().isGif(element.path)) {
        msg[2] = "${DateTime
            .now()
            .microsecondsSinceEpoch}${Random().nextInt(10000)}${element.name}";
        await compute((message) =>
            saveOther(message[0], message[1], message[2]), msg);
      }
      else {
        msg[2] = "${DateTime
            .now()
            .microsecondsSinceEpoch}${Random().nextInt(10000)}.jpg";
        compute((message) => saveImage(message[0], message[1], message[2]),
            msg);
      }
      var path = "${msg[1]}/${msg[2]}";
      list[path] = element.path;
      diary_data.Gallery.add(path);
      setState(() {

      });
    });
    context.pop();
  }

  void onTapMedia(int index) async{
    var path = diary_data.Gallery[index];

    if(isReadOnly){
      context.push("/mediaview",extra: list[path]);
    }
    else{
      var memo = await getMemo(path);

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("delete").tr(),
                  onTap: () {
                    diary_data.Gallery.removeAt(index);
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
                    showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController te_controller = TextEditingController();
                          te_controller.text = memo == "null" ? "":memo;
                          return AlertDialog(
                            title: Text("memo").tr(),
                            actions: [
                              TextField(
                                minLines: 1,
                                maxLines: 2,
                                maxLength: 100,
                                autofocus: true,
                                controller: te_controller,
                              ),
                              TextButton(
                                  onPressed: () async{
                                    var memo = te_controller.text;
                                    if(memo != ""){
                                      saveMemo(path,te_controller.text);
                                      context.pop();
                                    }
                                  },
                                  child: Text("memo").tr()
                              )
                            ],
                          );
                        }
                    );
                  },
                )
              ],
            );
          }
      );

    }
  }

  @override
  void initState() {
    Diary_Load();
    moveTop();
    MediaKit.ensureInitialized();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Base(
        child: Scaffold(
          appBar: DiaryPageAppBar(),
          body: DiaryPageBody(),
          bottomNavigationBar: DiaryBottomAppBar(),
        )
    );
  }

  Widget Base({required Widget child}){
    return PopScope(
        canPop: isReadOnly,
        onPopInvoked: (b) {
          save();
          context.pop();
        },
        child: Scaffold(
          body: child,
        )
    );
  }

  AppBar DiaryPageAppBar(){
    return AppBar(
      title: Text("Diary").tr(),

      actions: [
        if(isReadOnly)
          PopupMenuButton(
              position: PopupMenuPosition.under,
              tooltip: "",
              itemBuilder: (context){
                return [
                  PopupMenuItem(
                    height: 30,
                    onTap: () {
                      isReadOnly = false;
                      setState(() {

                      });
                    },
                    child: Center(
                      child: const Text(
                        "Edit",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        softWrap: true,
                      ).tr(),
                    ),
                  ),
                ];
              }
          )
      ],
    );
  }

  Widget DiaryPageBody(){
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: getDiaryWidth(context),
        margin: EdgeInsets.all(20),
        child: ListView.builder(
            controller: List_Controller,
            itemCount: 4,
            shrinkWrap: true,
            reverse: true,
            itemBuilder: (context,index) {
              switch(index){
                case 0:
                  return QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        scrollable: false,
                        controller: quillController,
                        readOnly: isReadOnly,
                        showCursor: !isReadOnly,
                        placeholder: "Placeholder".tr(),
                      )
                  );
                case 1:
                  if(list.isEmpty) return Container();
                  return MediaListView();
                case 2:
                  return Container(
                    child: Text(
                      getDayFormat(context).format(diary_data.day),
                      textAlign: TextAlign.center,
                    ),
                  );
                case 3:
                  return Column(
                    children: [
                      InkWell(
                        child: Image.asset("assets/Emojis/Test_Emoji.png",height: 50,width: 50,),
                        onTap: (isReadOnly) ? null: () {
                          print("sd");
                        },
                      )
                    ],
                  );
              }
            }
        ),
      ),
    );
  }

  Widget MediaListView(){
    return Stack(
      children: [
        Container(
          width: getDiaryWidth(context),
          height: getDiaryWidth(context)*2/3,
          child: PageView.builder(
            itemCount: diary_data.Gallery.length,
            itemBuilder: (context,index) {

              var path = list[diary_data.Gallery[index]];
              var media;

              File file = File(path!);
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
              else{

                if(!File_Tool().isVideoFile(path)){

                  media = Image(image: FileImage(file),fit: BoxFit.cover);

                }
                else{

                  if(videos.containsKey(path)){
                    media = videos[path];
                  }
                  else{
                    final player = Player();
                    final controller = VideoController(player);
                    player.open(Media(path),play: false);
                    media = Video(
                        width: 480,
                        controller: controller,
                        controls: null,
                        fill: Colors.transparent,
                        filterQuality: FilterQuality.none,
                        fit: BoxFit.cover
                    );
                    videos[path] = media;
                  }

                }

                return KeepWidget(
                    child:InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,

                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: media
                        ),
                      ),
                      onTap: () {
                        onTapMedia(index);
                      },
                    )
                );

              }

            },
            onPageChanged: (index){
              nowPage = index+1;
              setState(() {

              });
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey
            ),
            child: Text(
              " ${nowPage}/${list.length} ",
              style: TextStyle(
                  color: Theme.of(context).primaryColor
              ),
            ),
          ),
        )
      ]
    );
  }

  Widget ToolBar(){

    var iconShape = IconButtonData(
      style: ButtonStyle(
          shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) => BeveledRectangleBorder())
      ),
    );

    return QuillSimpleToolbar(
        configurations: QuillSimpleToolbarConfigurations(
            controller: quillController,
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
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context){
                        return  const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    );
                    MediaButton();
                  }
              )
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

  Row? DiaryBottomAppBar(){
    return isReadOnly ? null:
    Row(
      children: [
        Expanded(child: ToolBar()),
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
    );
  }

}

