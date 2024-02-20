
import 'dart:async';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:door/Tools/file_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_media_info/flutter_media_info.dart';
import 'package:latlong2/latlong.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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


  @override
  void initState() {

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    gps = getGps(widget.media);

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
        child: PageView(
          controller: pageviewcontroller,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                maxScale: 10,
                minScale: 0.01,
                child: isImage ?
                Image(image: FileImage(File(widget.media)),fit: BoxFit.contain,):
                Video(
                  controller: controller,
                  controls: null,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
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
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        // onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
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
