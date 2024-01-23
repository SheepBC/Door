
import 'package:door/Providers/setting.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Theme_SettingPage extends StatefulWidget {
  const Theme_SettingPage({super.key});

  @override
  State<Theme_SettingPage> createState() => _Theme_SettingPageState();
}

class _Theme_SettingPageState extends State<Theme_SettingPage> {

  getTile(ThemeMode mode,ThemeMode group,Setting setting){
    return RadioListTile(
      value: mode,
      title: Text(mode.name).tr(),
      groupValue: group,
      onChanged: (value){
        setting.theme.setMode(value!);
        setting.change();
        setState(() {

        });
      },
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<Setting>(builder: (context,setting,widget) {

      var _mode = setting.theme.mode;

      return Scaffold(
        appBar: AppBar(title: Text("Theme").tr()),
        body: ListView(
          children: [
            getTile(ThemeMode.system, _mode,setting),
            getTile(ThemeMode.light, _mode,setting),
            getTile(ThemeMode.dark, _mode,setting),

          ],
        ),
      );
    }
    );
  }

}
