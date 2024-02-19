

import 'package:flutter/material.dart';

class KeepWidget extends StatefulWidget{
  KeepWidget({super.key,required this.child});

  Widget child;

  @override
  State<KeepWidget> createState() => _KeepWidgetState();
}

class _KeepWidgetState extends State<KeepWidget> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
