
import 'dart:io';

import 'package:flutter/material.dart';

class Media_ViewPage extends StatefulWidget {
  Media_ViewPage({super.key,required this.media});

  String media;

  @override
  State<Media_ViewPage> createState() => _Media_ViewPageState();
}

class _Media_ViewPageState extends State<Media_ViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          child: Image(image: FileImage(File(widget.media)),fit: BoxFit.contain,),
          maxScale: 10,
          minScale: 0.01,
        ),
      ),
    );
  }
}
