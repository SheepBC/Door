
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  void initState() {
   load();

    super.initState();
  }

  void load() async{
    var file = File("D:\\Code\\Flutter\\Door\\Media/1708867756535182867.jpg");
    var bytes = file.readAsBytesSync();
    var data = await readExifFromBytes(bytes);

    print(data["GPS GPSLongitude"]);

    data.entries.forEach((element) {
      print("${element.key} : ${element.value} ,${data[element.key]}");
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
