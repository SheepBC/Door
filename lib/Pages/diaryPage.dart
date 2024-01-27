
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DiaryPage extends StatefulWidget {
  DiaryPage({super.key,required this.day});

  DateTime day;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {

  double getWidth(BuildContext context){
    var size = MediaQuery.of(context).size;
    var aspectRatio = size.aspectRatio; //세로/가로
    if(aspectRatio >= 3/2) return size.width/2;
    return size.width;
  }

  @override
  Widget build(BuildContext context) {
    var day = widget.day;

    return Scaffold(
      appBar: AppBar(
        title: Text("Diary").tr(),
      ),
      body: Center(
        child: Container(
          width: getWidth(context),
          margin: EdgeInsets.all(20),
          child: ListView(
            children: [
              Container(child: Icon(Icons.ac_unit,size: 100,),margin: EdgeInsets.all(20),),
              Text("${day.year}.${day.month}.${day.day}",textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }
}
