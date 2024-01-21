
import 'package:door/Providers/theme_setting.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Theme_Setting>(builder: (context,theme_setting,widget) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextButton(
                onPressed: () {
                  if(theme_setting.getMode == ThemeMode.light) {
                    theme_setting.setMode(ThemeMode.dark);
                  } else {
                    theme_setting.setMode(ThemeMode.light);
                  }
                },
                child: Text(theme_setting.getMode.name).tr()
            ),
            TextButton(
                onPressed: () {
                  if(context.locale.languageCode == "ko") {
                    context.setLocale(Locale("en","US"));
                  } else {
                    context.setLocale(Locale("ko","KR"));
                  }
                },
                child: Text(context.locale.languageCode).tr()
            )
          ],
        ),
        floatingActionButton: IconButton(
          onPressed: (){context.push("/main");},
          icon: Icon(Icons.home),
        ),

      );
    });
  }
}
