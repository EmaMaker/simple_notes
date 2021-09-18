import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notes_app/components/storage.dart';
import 'package:notes_app/screens/home/home.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key, required this.storage}) : super(key: key);
  final CounterStorage storage;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 55,
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
              ListTile(
              isThreeLine: false,
                leading: Icon(Icons.sort),
                title: Text("Sort By:"),
                subtitle: Text("WIP"),
              ),
            ListTile(
              
              leading: Icon(Icons.train),
              title: Text("Theme"),
              subtitle: Text("WIP"),
            ),
            ListTile(
              
              leading: Icon(Icons.info_outline_rounded),
              title: Text("About"),
              subtitle: Text("Info about this app"),
              onTap:  () => _aboutDialog(context),
            ),
          ]),
        ),
        onWillPop: () async {
          _toPrevious();
          return true;
        });
  }

  void _toPrevious() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(storage: widget.storage)));
  }
  void _aboutDialog(BuildContext context) {
    // debugdebugPrint("Clicked title");
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AboutDialog(
            applicationName: "Simple Notes",
            applicationLegalese: "Made with <3 by EmaMaker.\nSource Code available under GPL v3.0 on https://github.com/EmaMaker/simple_notes",
            applicationVersion: "v1.0",
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
