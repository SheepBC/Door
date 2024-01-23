
import 'package:door/Providers/setting.dart';
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
    return Consumer<Setting>(builder: (context,setting,widget) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextButton(
                onPressed: () {
                  print("object");
                  if(setting.theme.getMode == ThemeMode.light) {
                    setting.theme.setMode(ThemeMode.dark);
                  } else {
                    setting.theme.setMode(ThemeMode.light);
                  }
                  setting.change();
                },
                child: Text(setting.theme.getMode.name).tr()
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
            ),
            ListTile(
              leading: Icon(Icons.language_sharp),
              title: Text("언어"),
              onTap: () {
                print("object");
              },
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
