
import 'dart:async';

import 'package:door/Tools/Diary_Tool/diary_data.dart';
import 'package:door/Tools/file_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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
  List<Marker> marks = [];

  var allLoad = false;

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
    //context.pop();
  }

  void markLoad(){
    var st = getMarkers();
    st.listen((event) {
      if(event != null){
        marks = event;
      }
      else{
        print("zz");
        allLoad = true;
      }
      setState(() {

      });
    });
  }

  @override
  void initState() {
    markLoad();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {load();});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: IconButton(icon: Icon(Icons.add),onPressed: () {
        setState(() {

        }); 
      },),),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialZoom: 17,
            minZoom: 2,
            maxZoom: 19,
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
          if(allLoad)
            MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                    markers: marks,
                    disableClusteringAtZoom: 18,
                    maxClusterRadius: 50,
                    builder: (context,marks){
                      return Container(
                        child: Text("${marks.length}"),
                        decoration: BoxDecoration(color: Colors.blue),
                      );
                    }
                )
            ),
          if(!allLoad)
            MarkerLayer(markers: marks)
        ],
      ),
    );
  }
}

Stream<List<Marker>?> getMarkers() async*{
  var list = await getDiaryAll();

  List<Marker> marks = [];
  int last_index = 0;

  for(Diary_Data element in list){
    for(String path in element.Gallery){
      LatLng? point = await compute((message) => getGps(path), path);
      if(point != null){
        marks.add(Marker(
            point: point,
            child: Icon(Icons.ac_unit,color: Colors.red)
        ));
      }
    }
    print("${marks.length},${last_index}");
    if(marks.length-last_index >=5) {
      yield marks;
      last_index = marks.length;
    }
  }
  yield marks;
  print("Closed");
  yield null;

}


