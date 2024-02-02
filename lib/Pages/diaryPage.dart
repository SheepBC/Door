
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:door/Diary_Tool/diary_data.dart';
import 'package:go_router/go_router.dart';


class DiaryPage extends StatefulWidget {
  DiaryPage({super.key,required this.diary});
  
  Diary_Data diary;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  
  QuillController quillController = QuillController.basic();
  var isReadOnly = true;

  double getWidth(BuildContext context){
    var size = MediaQuery.of(context).size;
    var aspectRatio = size.aspectRatio; //세로/가로
    if(aspectRatio >= 3/2) return size.width/2;
    return size.width;
  }

  void load() async{
    await widget.diary.Load();
    if(widget.diary.content == ""){
      isReadOnly = false;
      setState(() {

      });
    }
    else {
      var json = jsonDecode(widget.diary.content);
      quillController.document = Document.fromJson(json);

      if(quillController.document.toPlainText() == "\n"){
        isReadOnly = false;
      }

      setState(() {

      });
    }
  }

  void save(){
    var json = jsonEncode(quillController.document.toDelta().toJson());
    widget.diary.content = json;
    widget.diary.save(widget.diary);
  }

  @override
  void initState() {
    super.initState();
    load();

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
                          child: Text("Edit").tr(),
                          height: 20,
                          onTap: () {
                            isReadOnly = false;
                            setState(() {

                            });
                          },
                        ),
                      ];
                    },
                    position: PopupMenuPosition.under,
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
                      Container(
                        child: Text(
                          "${DateFormat("Date Format".tr(),context.locale.languageCode).format(widget.diary.day)}",
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
                Expanded(child: ToolBar(controller: quillController,context: context,)),
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


/*
class DiaryPage extends StatefulWidget {
  DiaryPage({super.key,required this.Diary});

  Diary_Data Diary;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {

  QuillController controller = QuillController.basic();

  double getWidth(BuildContext context){
    var size = MediaQuery.of(context).size;
    var aspectRatio = size.aspectRatio; //세로/가로
    if(aspectRatio >= 3/2) return size.width/2;
    return size.width;
  }

  void showEmojiList(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Text("dasdsd"),
                GridView(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3
                  ),
                  children: getEmojiList(),
                )
              ],
            ),
          );
        }
    );
  }

  List<Widget> getEmojiList(){
    List<Widget> list = [];

    Emoji.values.forEach((element) {
      list.add(IconButton(
          onPressed: () {
            widget.Diary.emojis.add(element);
          },
          icon: element.icon
      ));
    });

    return list;
  }

  void getDocument() async{
    await widget.Diary.Load();
    var data = widget.Diary.content;
    if(data != ""){
      var json = jsonDecode(widget.Diary.content);
      controller.document = Document.fromJson(json);
    }
  }

  @override
  void initState() {
    getDocument();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var day = widget.Diary.day;
    return Scaffold(
      body: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text("Diary").tr(),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: getWidth(context),
            margin: EdgeInsets.all(10),
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              children: [
                QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    controller: controller,
                    readOnly: false,
                    placeholder: "오늘 나는 하늘을 보았다.",
                    //minHeight: getMinHeight()
                  ),
                ),
                SizedBox(
                  height: getWidth(context)*9/16,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Card(
                        child: InkWell(
                          child: Icon(Icons.add),
                          onTap: () {

                          },
                        ),
                      )
                    ],
                  ),
                ),
                Text("${DateFormat("Date Format".tr(),context.locale.languageCode).format(day)}",textAlign: TextAlign.center,),
                Container(
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => showEmojiList(context),
                  ),
                  margin: EdgeInsets.all(20),
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: Row(
          children: [
            Expanded(child: ToolBar(controller: controller,)),
            IconButton(
                onPressed: () {
                  widget.Diary.content = jsonEncode(controller.document.toDelta().toJson());
                  widget.Diary.save(widget.Diary);
                },
                icon: Icon(Icons.save)
            )
          ],
        ),
      ),
    );
  }

}

 */

class ToolBar extends StatefulWidget {
  ToolBar({super.key,required this.controller,required this.context});

  QuillController controller;
  BuildContext context;

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
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
              tooltip: "사진",
              onPressed: () {
              }
            ),
          ],

          buttonOptions: QuillSimpleToolbarButtonOptions(
            bold: QuillToolbarToggleStyleButtonOptions(
                tooltip: "bold".tr(),
                iconTheme: QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) => Theme.of(context).colorScheme.primary),
                      shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) => BeveledRectangleBorder(
                      ))
                    ),
                  )
                )
            ),
          )
        )

    );
  }
}

