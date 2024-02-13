
import 'dart:io';

import 'package:door/Diary_Tool/diary_data.dart';
import 'package:door/Pages/Settings/language_settingPage.dart';
import 'package:door/Pages/Settings/theme_settingPage.dart';
import 'package:door/Pages/diaryPage.dart';
import 'package:door/Pages/mediaViewPage.dart';
import 'package:door/Pages/settingPage.dart';
import 'package:door/Pages/testPage.dart';
import 'package:door/Providers/setting.dart';
import 'package:door/Providers/theme_setting.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'Pages/mainPage.dart';
import 'Tools/custom_scrollbehavior.dart';
import 'Pages/Settings/font_settingPage.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  Size size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
  //print(size.width);

  if(Platform.isAndroid){
    if(size.width <650) SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  var setting = Setting();
  setting.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Setting>(create: (context) => setting),
      ],
      child: EasyLocalization(
        supportedLocales: [Locale("en","US"),Locale("ko","KR")],
        path: "assets/translations",
        fallbackLocale: Locale("en","US"),
        child: MyApp(),
      ),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    var goRoute = GoRouter(

      initialLocation: "/main",
      routes: [
        GoRoute(path: "/main",builder: (context,state) => MainPage()),
        GoRoute(path: "/setting",builder: (context,state) => SettingPage()),
        GoRoute(path: "/langsetting",builder: (context,state) => Language_SettingPage()),
        GoRoute(path: "/fontsetting",builder: (context,state) => Font_SettingPage()),
        GoRoute(path: "/themesetting",builder: (context,state) => Theme_SettingPage()),
        GoRoute(path: "/diary",builder: (context,state) {
          DateTime day = DateTime.parse(state.extra.toString());
          return DiaryPage(day: day);
        }),
        GoRoute(path: "/mediaview",builder: (context,state) {
          return Media_ViewPage(media: state.extra.toString());
        }),

        GoRoute(path: "/test",builder: (context,state) => TestPage()),
      ],
    );

    return Consumer<Setting>(
        builder: (context,setting,widget) {
          return MaterialApp.router(
            //페이지 이동
            routerConfig: goRoute,

            //테마
            themeMode: setting.theme.getMode,
            darkTheme: setting.theme.getDarkMode,
            theme: setting.theme.getLightMode,
            builder: (context,widget) => setting.theme.getMediaQuery(context, widget!),
            //다국화
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            //마우스 움직임
            scrollBehavior: MouseDragScrollBehavior(),

            debugShowCheckedModeBanner: false,

          );
        }
    );
  }
}
