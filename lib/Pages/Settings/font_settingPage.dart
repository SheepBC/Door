
import 'package:door/Providers/setting.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Font_SettingPage extends StatefulWidget {
  const Font_SettingPage({super.key});

  @override
  State<Font_SettingPage> createState() => _Font_SettingPageState();
}

class _Font_SettingPageState extends State<Font_SettingPage> {

  getTile(font_list font,font_list group,Setting setting){
    return RadioListTile(
      value: font,
      title: Text(font.name).tr(),
      groupValue: group,
      onChanged: (value){
        setting.theme.setFont(font);
        setting.change();
        setting.save(setting);
        //print(setting.theme.getLightMode.textTheme.titleSmall!.fontFamily);
        setState(() {

        });
      },
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  @override
  Widget build(BuildContext context) {


    return Consumer<Setting>(builder: (context,setting,widget) {

      var slider_v = (setting.theme.font_size*10).round()/10;
      var _font = setting.theme.get_Font;

      return Scaffold(
        appBar: AppBar(title: Text("Font").tr()),
        body: Column(
          children: [
            Center(
              child: Container(
                child: Text("too big to see,\ntoo small to see...").tr(),
              ),
            ),
            Slider(
                value: slider_v,
                min: 0,
                max: 2.5,
                autofocus: true,
                divisions: 25,
                label: slider_v.toString(),
                onChanged: (value) {
                  setting.theme.setFont_Size(value);
                  setting.change();
                  slider_v = value;
                  setState(() {

                  });
                }
            ),
            Expanded(child: ListView(
              children: [
                getTile(font_list.Dovemayo, _font,setting),
                getTile(font_list.Nanum_JungHagSaeng, _font,setting),
                getTile(font_list.Font_Basic, _font,setting),
              ],
            ),)
          ],
        )
      );
    }
    );
  }
}
