
import 'dart:async';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:door/Diary_Tool/diary_tool.dart';
import 'package:door/Tools/file_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:latlong2/latlong.dart';

class Media_ViewPage extends StatefulWidget {
  Media_ViewPage({super.key,required this.media});

  String media;

  @override
  State<Media_ViewPage> createState() => _Media_ViewPageState();
}

class _Media_ViewPageState extends State<Media_ViewPage> {

  var showAppBar = true;
  var showFloatingButton = false;
  var isImage = true;

  late final player = Player();
  late final controller = VideoController(player);
  var isPlaying = false;

  double volum = 100.0;
  double nowTime = 0.001;
  int time = 1;
  String label = Duration().toString();
  double changeTime = -1;
  var isChanging = false;
  var seek = Duration.zero;

  var gps;
  var pageviewcontroller = PageController();

  void setGps() async{
    gps = await getGps(widget.media);
  }

  @override
  void initState() {

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    setGps();

    if(File_Tool().isVideoFile(widget.media)){
      isImage = false;
      MediaKit.ensureInitialized();
      player.open(Media(widget.media),play: false);

      Timer.periodic(
          Duration(milliseconds: 250),
              (timer) {
                if(changeTime >= 0){
                  var change = player.state.duration.inMilliseconds*changeTime;
                  player.seek(Duration(milliseconds: change.toInt()));
                  changeTime = -1;
                }
                nowTime = player.state.buffer.inMilliseconds/player.state.duration.inMilliseconds;
                label = player.state.buffer.toString();
                setState(() {

                });

              }
      );

    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: !showAppBar ? null:AppBar(),
      body: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          showAppBar = !showAppBar;
          setState(() {

          });
        },
        onDoubleTap: () {
          print("sd");
        },
        child: Media_View(path: widget.media, controller: controller),
        /*
        child: PageView(
          controller: pageviewcontroller,
          children: [
            if(gps != null)
              FlutterMap(
                options: MapOptions(
                    zoom: 17.5,
                    center: gps,
                    minZoom: 2,
                    maxZoom: 18.45
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        // onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                          point: gps,
                          builder: (context) {
                            return Icon(Icons.add);
                          }
                      )
                    ],
                  )
                ],
              )
          ],

          onPageChanged: (page) {
            if(page != 0){
              showAppBar = false;
              showFloatingButton =true;
            }
            else {
              showAppBar = true;
              showFloatingButton = false;
            }
            setState(() {

            });
          },
        ),
        */
      ),
      bottomNavigationBar: (!showAppBar || isImage) ? null:BottomAppBar(
        height: 90,
        child: Column(
          children: [
            StreamBuilder<PlayerState>(
                stream: Stream.value(player.state),
                builder: (context,state) {

                  return ProgressBar(
                    progress: isChanging ? seek:state.data!.position,
                    total: state.data!.duration,
                    timeLabelLocation: TimeLabelLocation.sides,
                    onSeek: (duration) async{
                      seek = duration;
                      isChanging = true;
                      await player.seek(duration);
                      isChanging = false;
                    },
                  );
                }
            ),
            Row(
              children: [
                IconButton(
                    onPressed: (){
                      player.playOrPause();
                    },
                    icon: Icon(player.state.playing ? Icons.pause :Icons.play_arrow)
                ),
                Icon(volum == 0.0 ?Icons.volume_off: Icons.volume_up),
                Container(
                  width: 100,
                  child: SliderTheme(
                    data: SliderThemeData(
                        trackHeight: 1,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 5
                        ),
                        overlayShape: SliderComponentShape.noThumb
                    ),
                    child: Slider(
                      value: volum,
                      max: 100.0,
                      min: 0.0,
                      label: volum.toString(),
                      onChanged: (value) {
                        volum = value;
                        setState(() {

                        });
                        player.setVolume(value);
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),

      floatingActionButton: !showFloatingButton ? null:FloatingActionButton.small(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            pageviewcontroller.jumpToPage(0);
          }
      ),

      extendBodyBehindAppBar: true,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    player.dispose();
    super.dispose();
  }
}

class Media_View extends StatefulWidget {
  Media_View({super.key,required this.path,required this.controller});

  String path;
  VideoController controller;

  @override
  State<Media_View> createState() => _Media_ViewState();
}

class _Media_ViewState extends State<Media_View> {

  var isImage = true;

  var gps;
  var day;
  var memo;

  int drag = 0;
  double max_Up_persent = 1/3;
  double max_Down_persent = 2/3;
  bool isChanging = false;
  bool isMax = false;
  Color infoBoxColor() {
    var base = Theme.of(context).backgroundColor;
    var result = Color.fromARGB((255*drag/getInfoMax()).toInt(), base.red, base.green, base.blue);
    return result;
  }

  void loadInfo() async{
    gps = await getGps(widget.path);
    day = await getDay(widget.path);
    memo = await getMemo(widget.path);
    setState(() {
      print("${gps},${day},${memo}");
    });
  }

  int getInfoMax(){
    return (MediaQuery.of(context).size.height*max_Up_persent).toInt();
  }

  int getInfoMaxDown(){
    return (getInfoMax()*max_Down_persent).toInt();
  }

  @override
  void initState() {

    if(File_Tool().isVideoFile(widget.path)) isImage = false;
    loadInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: InteractiveViewer(
              maxScale: 10,
              minScale: 0.01,
              child: isImage ?
              Image(image: FileImage(File(widget.path)),fit: BoxFit.contain,):
              Video(
                controller: widget.controller,
                controls: null,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
          if(drag >0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: drag.toDouble(),
                decoration: BoxDecoration(color: infoBoxColor()),
                child: isChanging ? null:Column(
                  children: [
                    if(day != null)
                      Text(day),
                    if(gps != null)
                      Text(gps),
                    if(memo != null)
                      Text(memo)
                  ],
                ),
              ),
            ),
        ],
      ),
      onVerticalDragStart: (detaill) {
        print("Start: ${detaill.globalPosition}");
        isChanging = true;
      },
      onVerticalDragUpdate: (detail){
        var add = detail.primaryDelta;
        if(drag >= getInfoMax()) {
          if(add! > 0){
            drag -= add.toInt();
          }
        }
        else{

          if(add != null) drag -= add.toInt();
        }

        setState(() {

        });
      },
      onVerticalDragEnd: (detaill) {
        print("End: ${drag}");
        isChanging = false;
        if(drag >= getInfoMax()){
          isMax = true;
        }
        else{
          if(drag >= getInfoMaxDown() && isMax){
            drag = getInfoMax();
          }
          else{
            drag = 0;
            isMax = false;
          }
        }
        setState(() {

        });
      },
    );

    return PageView(
      scrollDirection: Axis.vertical,
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: InteractiveViewer(
            maxScale: 10,
            minScale: 0.01,
            child: isImage ?
            Image(image: FileImage(File(widget.path)),fit: BoxFit.contain,):
            Video(
              controller: widget.controller,
              controls: null,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.red),
          child: Column(
            children: [
              if(day != null)
                Text(day),
              if(gps != null)
                Text(gps),
              if(memo != null)
                Text(memo)
            ],
          ),
        )
      ],
    );
  }
}

