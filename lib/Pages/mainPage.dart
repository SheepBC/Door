
import 'dart:ffi';

import 'package:door/Providers/setting.dart';
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
    return Consumer<Setting>(builder: (context,setting,widget) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title:Text(calender.focusDay.year.toString()),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  context.push("/setting");
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
                      TextSpan(
                          text: "${calender.focusDay.month}",
                          style: TextStyle(
                              fontSize: 50,
                              color: Theme.of(context).textTheme.titleMedium!.color,
                              fontFamily: setting.theme.font
                          )
                      ),
                      TextSpan(
                          text: "${months[calender.focusDay.month-1]}",
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).textTheme.titleMedium!.color,
                              fontWeight: FontWeight.bold,
                              fontFamily: setting.theme.font
                          )
                      )
                    ]
                ),
                textScaleFactor: setting.theme.font_size,
              ),
              Expanded(child: Container(child: calender,width: getWidth(),margin: EdgeInsets.all(20),)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {

          },

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

                var theme = Theme.of(context);

                var color = theme.textTheme.titleSmall!.color;
                if (day.isAfter(DateTime.now())) color = theme.disabledColor;
                
                if(day.weekday == DateTime.sunday) color = Colors.red.withOpacity(color!.opacity);
                if(day.weekday == DateTime.saturday) color = Colors.blue.withOpacity(color!.opacity);

                return Container(
                  width: 37,
                  child: Center(child: Text("${day.day}",style: TextStyle(color: color,fontSize: 24),)),
                );
              },
            todayBuilder: (context,day,_) {
              var color = Theme.of(context).textTheme.titleSmall!.color;
              if(day.weekday == DateTime.sunday) color = Colors.red;
              if(day.weekday == DateTime.saturday) color = Colors.blue;
              return Container(
                width: 37,
                child: Center(child: Text("${day.day}", style: TextStyle(color: color,fontSize: 24),),),
                decoration: BoxDecoration(shape: BoxShape.circle,color: Theme.of(context).highlightColor),

              );
            }
          ),

          onDaySelected: (day,_) {
            print("d");
          },

        );;
      },
      onPageChanged: (index){

        var month = index%12;
        var year = ((index-month)/12).toInt();

        widget.focusDay = DateTime(year,month);

        widget.onChange();
      },

    );
  }
}

