import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
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
                  Navigator.pop(context);
                })
              },
            ),
          ),
          body: ListView(),
        ),
        onWillPop: () async {
          setState(() {
            Navigator.pop(context);
          });
          return true;
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
