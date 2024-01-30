
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:door/Diary_Tool/diary_data.dart';

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

class ToolBar extends StatefulWidget {
  ToolBar({super.key,required this.controller});

  QuillController controller;

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  @override
  Widget build(BuildContext context) {
    return QuillToolbar.simple(
        configurations: QuillSimpleToolbarConfigurations(
          controller: widget.controller,
          toolbarIconAlignment: WrapAlignment.start,

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
            )
          ]
        )
    );
  }
}

