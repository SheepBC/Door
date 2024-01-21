
import 'package:door/Pages/testPage.dart';
import 'package:door/Providers/theme_setting.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'Pages/mainPage.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Theme_Setting>(create: (context) => Theme_Setting())
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
  Widget build(BuildContext context) {
    return Consumer<Theme_Setting>(
        builder: (context,themem_setting,widget) {
          return MaterialApp.router(

            routerConfig: GoRouter(
              initialLocation: "/test",
              routes: [
                GoRoute(path: "/main",builder: (context,state) => MainPage()),
                GoRoute(path: "/test",builder: (context,state) => TestPage()),
              ]
            ),

            //테마
            themeMode: themem_setting.getMode,
            darkTheme: themem_setting.getDarkMode,
            theme: themem_setting.getLightMode,
            //다국화
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

          );
        }
    );
  }
}
