
import 'package:door/Providers/setting.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Language_SettingPage extends StatefulWidget {
  const Language_SettingPage({super.key});

  @override
  State<Language_SettingPage> createState() => _Language_SettingPageState();
}

class _Language_SettingPageState extends State<Language_SettingPage> {
  
  getTile(Locale locale,Locale group){
    return RadioListTile(
      value: locale,
      title: Text(locale.languageCode).tr(),
      groupValue: group,
      onChanged: (value){
        context.setLocale(value!);
        setState(() {

        });
      },
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context,setting,widget) {

      Locale _locale = context.locale;

      return Scaffold(
        appBar: AppBar(title: Text("Language").tr()),
        body: ListView(
          children: [
            getTile(Locale("en","US"), _locale),
            getTile(Locale("ko","KR"), _locale)
          ],
        ),
      );
    }
    );
  }
}
