
import 'dart:async';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:door/Tools/Diary_Tool/diary_tool.dart';
import 'package:door/Tools/file_tool.dart';
import 'package:door/Tools/other_tool.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Media_ViewPage extends StatefulWidget {
  Media_ViewPage({super.key,required this.list,required this.index});

  int index;
  List<String> list;

  @override
  State<Media_ViewPage> createState() => _Media_ViewPageState();
}

class _Media_ViewPageState extends State<Media_ViewPage> {

  late var nowMedia = widget.list[widget.index];

  var showAppBar = true;
  var showFloatingButton = false;
  var isImage = true;

  late var page_controller = PageController(initialPage: widget.index);


  void setAppBar(){
    showAppBar = !showAppBar;
    setState(() {

    });
  }

  @override
  void initState() {

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: !showAppBar ? null:AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
              PopupMenuItem(
                  child: const Text("Share").tr(),
                onTap: () async{
                    await Share.shareXFiles([XFile(nowMedia)]);
                },
              )
              ];
            },
          )
        ],
      ),
      body: PageView.builder(
        controller: page_controller,
        itemCount: widget.list.length,
        itemBuilder: (context,index) {
          nowMedia = widget.list[index];
          return KeepWidget(child: Media_View(path: nowMedia,setAppBar: setAppBar,isShowAppBar: showAppBar,));
        },
      ),


      extendBodyBehindAppBar: true,
      extendBody: true,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}

class Media_View extends StatefulWidget {
  Media_View({super.key,required this.path,required this.setAppBar,required this.isShowAppBar});

  String path;
  Function setAppBar;
  bool isShowAppBar;

  @override
  State<Media_View> createState() => _Media_ViewState();
}

class _Media_ViewState extends State<Media_View> {

  var isImage = true;

  var gps;
  var day;
  var memo;

  bool getInfo = false;

  double max_Up_persent = 2/3;

  late final player = Player();
  late final controller = VideoController(player);
  var isPlaying = false;

  double volum = 100.0;
  double nowTime = 0.001;
  int time = 1;
  String label = const Duration().toString();
  double changeTime = -1;
  var isChanging = false;
  var seek = Duration.zero;

  var showInfoBox = false;

  int getInfoMax(){
    return (MediaQuery.of(context).size.height*max_Up_persent).toInt();
  }

  void setInfo() async{
    var value = await loadInfo(widget.path);
    gps = value[0];
    day = value[1];
    memo = value[2];
    setState(() {

    });
  }
  
  static void launch(){
    launchUrl(Uri.parse('https://openstreetmap.org/copyright'));
  }

  static void goMap(BuildContext context,var gps){
    context.push("/mappage",extra: gps);
  }


  @override
  void initState() {

    if(File_Tool().isVideoFile(widget.path)){
      isImage = false;
      MediaKit.ensureInitialized();
      player.open(Media(widget.path),play: false);

      Timer.periodic(
          const Duration(milliseconds: 250),
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

    }

    print("${isImage}${widget.path}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(!getInfo){
      getInfo = true;
      setInfo();
    }

    return Scaffold(
      body: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: InteractiveViewer(
            maxScale: 10,
            minScale: 0.01,
            child: isImage ?
            Image(image: FileImage(File(widget.path)),fit: BoxFit.contain,):
            Video(
              controller: controller,
              controls: null,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),

        onTap: () async{
          widget.setAppBar();
        },

        onDoubleTap: () async{
          showModalBottomSheet(
              context: context,
              builder: (context) => InfoBox()
          );
          /*
          showInfoBox = !showInfoBox;
          setState(() {

          });

           */
        },

      ),
      bottomNavigationBar: (!widget.isShowAppBar || isImage) ? null: bottom(),
      extendBodyBehindAppBar: true,
      extendBody: true,
    );

  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Widget bottom() {
    return BottomAppBar(
      height: 100,
      child: Column(
        children: [
          StreamBuilder<PlayerState>(
              stream: Stream.value(player.state),
              builder: (context,state) {

                return ProgressBar(
                  progress: isChanging ? seek:state.data!.position,
                  total: state.data!.duration,
                  buffered: state.data!.buffer,
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
                      thumbShape: const RoundSliderThumbShape(
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
    );
  }

  Widget InfoBox(){
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
          maxHeight:gps != null ? getInfoMax().toDouble():200,
          minWidth: 200
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
            constraints: const BoxConstraints(
                maxHeight: 75
            ),
            child: SingleChildScrollView(
              child: Text(memo.toString() == "null" ? "null".tr():memo.toString()),
            ),
          ),
          if(day != null)
            Container(
              margin: const EdgeInsets.only(left: 20,right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("${"Date".tr()}: ${day}"),
              ),
            ),
          if(gps != null)
            Expanded(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  margin: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: FlutterMap(
                      options: MapOptions(
                          zoom: 17.5,
                          center: gps,
                          minZoom: 2,
                          maxZoom: 18.45
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
                        InkWell(
                          //splashColor: Colors.transparent,
                          //highlightColor: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          onTap: () =>goMap(context,gps),
                          child: Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(2.5),
                            child: Icon(Icons.arrow_forward,color: Theme.of(context).primaryColor,),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                        )
                      ],
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          rotate: true,
                          markers: [
                            Marker(
                                point: gps,
                                child: Icon(Icons.location_on,color: Colors.red,)
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
            ),
          if(gps != null)
            Container(
              margin: const EdgeInsets.only(left: 20,right: 20,top: 0,bottom: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("${gps.latitude},${gps.longitude}"),
              ),
            ),
          if(gps != null)
            Container(
              margin: const EdgeInsets.only(left: 20,right: 20,top: 0,bottom: 20),
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).highlightColor
                  ),
                  onPressed: () => launchUrl(Uri.parse("https://www.google.com/maps/place/${gps.latitude},${gps.longitude}")),
                  child: const Text("Open Google Map")
              ),
            )
        ],
      ),
    );
  }

}

Future<List<dynamic>> loadInfo(String path) async{
  List<dynamic> list =[null,null,null];
  var token = RootIsolateToken.instance;
  list[0] = await getGps(path,token!);
  list[1] = await getDay(path);
  list[2] = await getMemo(path);
  return list;
}

