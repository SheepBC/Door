
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:door/Tools/Diary_Tool/diary_data.dart';
import 'package:door/Tools/custom_Marker_Layer.dart';
import 'package:door/Tools/file_tool.dart';
import 'package:door/Tools/other_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:door/Tools/Diary_Tool/diary_tool.dart';

class MapPage extends StatefulWidget {
  MapPage({super.key,this.center});

  LatLng? center;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  var mapController = MapController();
  List<customMark> marks = [];

  var isChange = false;
  var last_Zoom = 17.0;

  void load() async{
    if(widget.center != null) {
      mapController.move(widget.center!,18.45);
    }
    else{
      await Geolocator.requestPermission();
      var gps = await Geolocator.getCurrentPosition();
      var Center = LatLng(gps.latitude, gps.longitude);
      mapController.move(Center, 18.45);
    }
  }

  static void launch(){
    launchUrl(Uri.parse('https://openstreetmap.org/copyright'));
  }

  static void goBack(BuildContext context){
    context.pop();
  }

  void markLoad(BuildContext context){
    var st = getMarkers(context);
    st.listen((event) {
      if(event != null){
        marks = event;
      }
      else{
        print("zz");
      }
      setState(() {

      });
    });
  }

  @override
  void initState() {
    markLoad(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {load();});
    MediaKit.ensureInitialized();
    super.initState();
  }

  var con = SuperclusterMutableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialZoom: 17,
            minZoom: 2,
            maxZoom: 19,
          onPositionChanged: (position,b) {
            if(last_Zoom != mapController.zoom) isChange = true;
            last_Zoom = mapController.zoom;
          }
        ),
        nonRotatedChildren: [
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: launch,
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: InkWell(
              //splashColor: Colors.transparent,
              //highlightColor: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              onTap: () =>goBack(context),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(2.5),
                child: Icon(Icons.arrow_back,color: Theme.of(context).primaryColor,size: 30,),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).colorScheme.primary
                ),
              ),
            ),
          )
        ],
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          CustomMarkLayer(
              markers: marks,
              max_Distance: 50,
              height: 50,
              width: 50,
              build: (context,list){

                return InkWell(
                  child: Stack(
                    children: [
                      list[0].child,
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(child: Text("${list.length}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
                      )
                    ],
                  ),
                  onTap: () {
                    List<String> paths = [];
                    for(var mark in list){
                      var cMark = mark as customMark;
                      paths.add(cMark.path);
                    }
                    context.push("/mediaview",extra: [0,paths]);
                  },
                );
              }
          )
        ],
      ),
    );
  }



}

Widget markers(BuildContext context,List<Marker> marks){
  print("change!!!!!!");

  var option = MarkerClusterLayerOptions(
      markers: marks,
      disableClusteringAtZoom: 20,
      maxClusterRadius: 50,
      size: Size(50,50),
      builder: (context,marks){
        return SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              marks[0].child,
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Center(child: Text("${marks.length}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
              )
            ],
          ),
        );
      },
      spiderfyCluster: false,
      onClusterTap: (node) {
        List<String> paths = [];
        node.markers.forEach((element) {
          paths.add((element.marker as customMark).path);
        });
        context.push("/mediaview",extra: [0,paths]);
      }
  );

  print(option.markers.length);

  var result = MarkerClusterLayerWidget(options: option);
  print(result.options.markers.length);

  return result;
}


Stream<List<customMark>?> getMarkers(BuildContext context) async*{
  var list = await getDiaryAll();
  print("start: ${DateTime.now()}");
  List<customMark> marks = [];
  int last_index = 0;

  for(Diary_Data element in list){
    for(String path in element.Gallery){
      var token = RootIsolateToken.instance;
      BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
      LatLng? point = await compute((message) => getGps(path,token), path);
      if(point != null){
        marks.add(customMark(
            width: 50,
            height: 50,
            point: point,
            child: getMarkChild(path,context),
            path: path
        ));
      }
    }
    print("${marks.length},${last_index}");
    if(marks.length-last_index >=2) {
      yield marks;
      last_index = marks.length;
    }
  }
  yield marks;
  print("Closed");
  print("end: ${DateTime.now()}");
  yield null;

}

Widget getMarkChild(String path,BuildContext context){

  Widget media = Container();

  if(File_Tool().isVideoFile(path)){
    final player = Player();
    final controller = VideoController(player);
    player.open(Media(path),play: false);
    media = Video(
        width: 40,
        height: 40,
        controller: controller,
        controls: null,
        fit: BoxFit.cover,
    );
  }
  else{
    media = Image(
      width: 40,
      height: 40,
      image: FileImage(File(path)),
      fit: BoxFit.cover,
    );
  }

  return KeepWidget(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,

        child: Container(
          child: Center(
            child: ClipRRect(
              child: media,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10)
          ),
        ),

        onTap: (){
          context.push("/mediaview",extra: [0,[path]]);
        },

      )
  );
  /*
  기존 start: 2024-03-23 19:49:59.290798
      end: 2024-03-23 19:52:01.805690
      약 2분

  바꾼것 start: 2024-03-23 20:14:32.395400
        end: 2024-03-23 20:15:20.017111
        약 1분
   */

}

class customMark extends Marker{

  customMark({required super.point, required super.child,required super.width,required super.height,required this.path});

  double get width => super.width;
  double get hight => super.width;

  String path;

}

class testData extends ClusterDataBase{

  var per = 32;// 1당

  List<Marker> marks = [];

  double zoom;

  testData(this.marks,this.zoom);

  @override
  ClusterDataBase combine(covariant ClusterDataBase data) {
    var other = data as testData;
    var list = other.marks;

    var one = list[0];
    var one_point = CrsSimple().latLngToPoint(one.point, zoom);
    var other_point = CrsSimple().latLngToPoint(marks[0].point, zoom);

    var distance = sqrt(pow(one_point.x-other_point.x,2)+pow(one_point.y-other_point.y,2));
    //print(distance);
    if(distance <= per*200) list.addAll(marks);
    list = list.toSet().toList();
    return testData(list,zoom);

  }

}



