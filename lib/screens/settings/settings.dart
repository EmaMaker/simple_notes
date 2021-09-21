import 'package:flutter/material.dart';
import 'package:notes_app/components/storage.dart';
import 'package:notes_app/screens/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key, required this.storage}) : super(key: key);
  final CounterStorage storage;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    getTheme();
    getSortBy();

    super.initState();
  }

  String _theme = "";
  String _sortBy = "";

  void getTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      switch (savedThemeMode) {
        case AdaptiveThemeMode.dark:
          _theme = "Dark";
          break;
        case AdaptiveThemeMode.light:
          _theme = "Light";
          break;
        default:
          _theme = "Follow System";
          break;
      }
    });
  }

  void getSortBy() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortBy = prefs.getString("sortBy") ?? "Name";
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            title: InkWell(
              child: Text("Settings"),
            ),
            centerTitle: true,
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () => {
                setState(() {
                  _toPrevious();
                })
              },
            ),
          ),
          body: ListView(padding: EdgeInsets.all(8), children: [
            _settingsEntry(new Icon(Icons.filter_alt_outlined), "Sort by",
                _sortBy, _sortByDialog, context),
            _settingsEntry(new Icon(Icons.brightness_medium_outlined), "Theme",
                _theme, _themeDialog, context),
            _settingsEntry(new Icon(Icons.info_outline), "About",
                "Info about this app", _aboutDialog, context),
          ]),
        ),
        onWillPop: () async {
          _toPrevious();
          return true;
        });
  }

  ListTile _settingsEntry(Icon icon, String title, String? subtitle,
      Function(BuildContext) f, BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Container(
        width: 25,
        height: 50,
        child: icon,
      ),
      subtitle:
          subtitle == null ? null : (subtitle == "" ? null : Text(subtitle)),
      onTap: () => f(context),
    );
  }

  void _toPrevious() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(storage: widget.storage)));
  }

  void _sortByDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            title: const Text('Choose theme'),
            children: <Widget>[
              _radioListTile("Name", "Name", _sortBy, _setSortBy),
              _radioListTile(
                  "Last Modified", "Last Modified", _sortBy, _setSortBy),
            ],
          );
        });
  }

  void _themeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            title: const Text('Choose theme'),
            children: <Widget>[
              _radioListTile(
                  "Follow System", "Follow System", _theme, _setTheme),
              _radioListTile("Dark", "Dark", _theme, _setTheme),
              _radioListTile("Light", "Light", _theme, _setTheme),
            ],
          );
        });
  }

  RadioListTile _radioListTile(
      String title, String value, String groupValue, Function(dynamic) f) {
    return new RadioListTile(
        title: Text(title),
        value: value,
        groupValue: groupValue,
        onChanged: (dynamic newValue) {
          f(newValue);
        });
  }

  void _setTheme(dynamic newTheme) {
    // final prefs = await SharedPreferences.getInstance();

    // prefs.setString("theme", _theme);
    setState(() {
      _theme = newTheme;
      switch (_theme) {
        case "Dark":
          // sets theme mode to dark
          AdaptiveTheme.of(context).setDark();
          break;
        case "Light":
          // sets theme mode to light
          AdaptiveTheme.of(context).setLight();
          break;
        case "Follow System":
          // sets theme mode to system default
          AdaptiveTheme.of(context).setSystem();
          break;
      }
      Navigator.of(context).pop();
    });
  }

  void _setSortBy(dynamic newSortby) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("sortBy", newSortby);
    setState(() {
      _sortBy = newSortby;
      Navigator.of(context).pop();
    });
  }

  void _aboutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AboutDialog(
            applicationName: "Simple Notes",
            applicationLegalese:
                "Made with <3 by EmaMaker.\nSource Code available under GPL v3.0 on https://github.com/EmaMaker/simple_notes",
            applicationVersion: "v1.0",
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
