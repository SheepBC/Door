
import 'dart:ffi';

import 'package:door/Providers/theme_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:door/Tools/custom_scrollbehavior.dart';
import 'package:table_calendar/table_calendar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  late Calender calender;

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'June',
    'July',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];

  void change(){
    setState(() {

    });
  }

  double getWidth(){
    var size = MediaQuery.of(context).size;
    var aspectRatio = size.aspectRatio; //세로/가로
    if(aspectRatio >= 2/3) return size.height*2/3;
    return size.width;
  }


  @override
  void initState() {
    calender = Calender(change);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Theme_Setting>(builder: (context,theme_setting,widget) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title:Text(calender.focusDay.year.toString()),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  context.push("/test");
                },
                icon: Icon(Icons.settings)
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                    children: [
                      TextSpan(text: "${calender.focusDay.month}",style: TextStyle(fontSize: 50,color: Theme.of(context).textTheme.titleMedium!.color)),
                      TextSpan(text: "${months[calender.focusDay.month-1]}",style: TextStyle(fontSize: 15,color: Theme.of(context).textTheme.titleMedium!.color, fontWeight: FontWeight.bold))
                    ]
                ),
              ),
              Expanded(child: SizedBox(child: calender,width: getWidth(),)),
            ],
          ),
        ),
      );
    });
  }
}

class Calender extends StatefulWidget {
  Calender(this.onChange, {super.key});

  var focusDay = DateTime.now();
  final VoidCallback onChange;

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {

  late PageController controller;

  @override
  void initState() {
    controller = PageController(initialPage: widget.focusDay.year*12+widget.focusDay.month);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: controller,
      scrollBehavior: MouseDragScrollBehavior(),
      itemBuilder: (context, index) {

        var month = index%12;
        var year = ((index-month)/12).toInt();

        widget.focusDay = DateTime(year,month);

        var firstDay = DateTime(widget.focusDay.year,widget.focusDay.month,1);
        var lastDay = DateTime(widget.focusDay.year,widget.focusDay.month+1,0);

        return TableCalendar(

          focusedDay: widget.focusDay,
          firstDay: firstDay,
          lastDay: lastDay,

          headerVisible: false,
          daysOfWeekVisible: false,

          rowHeight: 52,

          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,

          ),
          calendarBuilders: CalendarBuilders(
              defaultBuilder: (context,day,_) {
                var color = Theme.of(context).textTheme.titleSmall!.color;
                if(day.weekday == DateTime.sunday) color = Colors.red;
                if(day.weekday == DateTime.saturday) color = Colors.blue;
                return Container(
                  width: 35,
                  child: Center(child: Text("${day.day}",style: TextStyle(color: color),)),
                );
              }
          ),

        );;
      },
      onPageChanged: (index){
        widget.onChange();
      },

    );
  }
}

