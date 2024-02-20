import 'package:door/Providers/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context, setting, widget) {
      return Scaffold(
        appBar: AppBar(),
        body: FlutterMap(
          options: MapOptions(
              center: LatLng(35,128),
              maxZoom: 18
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors')
                ]
            ),
            MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  builder: ((context, markers) {
                    return Text("${markers.length}");
                  }),
                  markers: [
                     Marker(
                         point: LatLng(35,128),
                         builder: (context) => Text("!")
                     ),
                    Marker(
                        point: LatLng(35.1,128),
                        builder: (context) => Text("!!")
                    ),
                    Marker(
                        point: LatLng(35,128.1),
                        builder: (context) => Text("!!")
                    )
                  ]
                )
            )
          ],
        ),
      );
    });
  }
}
