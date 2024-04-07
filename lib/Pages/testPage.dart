
import 'dart:io';
import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  var mapController = MapController();
  var crs = CrsSimple();

  @override
  void initState() {

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: Colors.red),
            ),
            MarkerLayer(
                markers: [
                  Marker(

                      point: LatLng(10,12),
                      child: TextButton(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(color: Colors.black45),
                        ),
                        onPressed: () {
                          print(CrsSimple().latLngToPoint(LatLng(10,12), mapController.zoom));
                          var p1 = CrsSimple().latLngToPoint(LatLng(10,12.234), mapController.zoom);
                          var p2 = CrsSimple().latLngToPoint(LatLng(10,28.234), mapController.zoom);

                          double result = (p1.x-p2.x)/(pow(2, mapController.zoom));

                          print("${p1.x},${p2.x},${result}");
                          //print(crs.latLngToPoint(LatLng(10,12.234), mapController.zoom));
                        },
                      )
                  ),
                  Marker(
                      point: LatLng(10,13),
                      child: TextButton(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(color: Colors.black45),
                        ),
                        onPressed: () {
                          print(CrsSimple().latLngToPoint(LatLng(10,13), mapController.zoom));
                          var p1 = CrsSimple().latLngToPoint(LatLng(10,12.234), mapController.zoom);
                          var p2 = CrsSimple().latLngToPoint(LatLng(10,28.234), mapController.zoom);

                          double result = (p1.x-p2.x)/(pow(2, mapController.zoom));

                          print("${p1.x},${p2.x},${result}");
                          //print(crs.latLngToPoint(LatLng(10,12.234), mapController.zoom));

                          //320
                        },
                      )
                  ),
                  Marker(
                      point: LatLng(10,14.5),
                      child: TextButton(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(color: Colors.black45),
                        ),
                        onPressed: () {
                          print(CrsSimple().latLngToPoint(LatLng(10,14.5), mapController.zoom));
                          var p1 = CrsSimple().latLngToPoint(LatLng(10,12.234), mapController.zoom);
                          var p2 = CrsSimple().latLngToPoint(LatLng(10,28.234), mapController.zoom);

                          double result = (p1.x-p2.x)/(pow(2, mapController.zoom));

                          print("${p1.x},${p2.x},${result}");
                          //print(crs.latLngToPoint(LatLng(10,12.234), mapController.zoom));
                        },
                      )
                  ),
                ]
            )
          ],
        ),
      )
    );
  }
}
