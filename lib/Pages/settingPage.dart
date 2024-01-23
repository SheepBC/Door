
import 'package:door/Providers/setting.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context,setting,widget) {
      return Scaffold(
        appBar: AppBar(title: Text("Setting").tr()),
        body: ListView(
          children: [

            ListTile(
              leading: Icon(Icons.language),
              title: Text("Language").tr(),
              onTap: () {
                context.push("/langsetting");
              },
            ),
            ListTile(
              leading: Icon(Icons.title),
              title: Text("Font").tr(),
              onTap: () {
                context.push("/fontsetting");
              },
            ),
            ListTile(
              leading: Icon(Icons.brush),
              title: Text("Theme").tr(),
              onTap: () {
                context.push("/themesetting");
              },
            )

          ],
        ),
      );
    }
    );
  }
}
