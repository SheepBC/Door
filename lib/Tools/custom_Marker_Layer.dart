import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CustomMarkLayer extends StatefulWidget {

  CustomMarkLayer({
    super.key,
    required this.markers,
    required this.max_Distance,
    required this.height,
    required this.width,
    required this.build
  });

  List<Marker> markers;
  double max_Distance;
  double width = 50;
  double height = 50;
  Widget Function(BuildContext context,List<Marker> markers) build;

  @override
  State<CustomMarkLayer> createState() => _CustomMarkLayerState();
}

class _CustomMarkLayerState extends State<CustomMarkLayer> {

  @override
  Widget build(BuildContext context) {
    var list = final_markers();

    return MobileLayerTransformer(
        child: (list.length == 0) ? Container(): Stack(
          children: list.last,
        )
    );
  }

  Iterable<List<Widget>> final_markers() sync*{

    final map = MapCamera.of(context);

    List<Widget> list = [];
    List<CustomMarker> result_list = [];

    for(final marker in widget.markers){

      final pxPoint = map.project(marker.point);
      final mapPoint = Point<double>(map.pixelOrigin.x.toDouble(), map.pixelOrigin.y.toDouble());
      final pos = pxPoint - mapPoint;

      var add = false;

      for(int index = 0;index<result_list.length;index++){
        var inList = result_list[index];
        if(pos.distanceTo(inList.pos) <= widget.max_Distance){
          var result_Pos = inList.pos.scaleBy(Point(inList.marker_list.length, inList.marker_list.length));
          result_Pos = result_Pos+pos;
          result_Pos = result_Pos.unscaleBy(Point(inList.marker_list.length+1, inList.marker_list.length+1));

          var result_Marker = inList.marker_list;
          result_Marker.add(marker);

          var result = CustomMarker(
              point: map.pointToLatLng(result_Pos),
              child: inList.child,
              pos: result_Pos,
              marker_list: result_Marker
          );

          result_list[index] = result;

          var out = Positioned(
            child: widget.build(context,result.marker_list),
            width: widget.width,
            height: widget.height,
            left: result.pos.x,
            top: result.pos.y,
          );

          list[index] = out;
          add = true;
          break;
        }
      }

      if(!add){
        var result = CustomMarker(
            point: marker.point,
            child: marker.child,
            pos: pos,
            marker_list: [marker]
        );

        result_list.add(result);

        var out = Positioned(
          child: widget.build(context,result.marker_list),
          width: widget.width,
          height: widget.height,
          left: result.pos.x,
          top: result.pos.y,
        );

        list.add(out);
      }

      yield list;

    }

  }

}

class CustomMarker extends Marker{

  Point<double> pos;
  List<Marker> marker_list;

  CustomMarker({
    required super.point,
    required super.child,
    required this.pos,
    required this.marker_list
  });

}