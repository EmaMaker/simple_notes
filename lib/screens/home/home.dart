import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes_app/components/storage.dart';
import 'package:notes_app/screens/home/components/MyListTile.dart';
import 'package:notes_app/screens/settings/settings.dart';

import 'dart:io';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.storage}) : super(key: key);
  final CounterStorage storage;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<GlobalKey<MyListTileState>> keys = [];

  List<File> _allFilesNames = [];
  late Iterable<MyListTile> tiles;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Simple Notes"),
            centerTitle: true,
            toolbarHeight: 50,
            actions: selectMode
                ? [btnAppBarMoreSelect()]
                : [btnAppBarMoreNoSelect(context)],
          ),
          body: FutureBuilder<List<File>>(
              future: widget.storage
                  .getAllFiles(), // a previously-obtained Future<String> or null
              builder:
                  (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text("No Notes (yet)"),
                    );
                  } else {
                    _allFilesNames = snapshot.data!;
                    return _buildList(context);
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Unspecified error"),
                  );
                } else {
                  return Center(
                      child: SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ));
                }
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              widget.storage.openNote(context, "");
            },
            tooltip: 'Take a new note',
            child: Icon(Icons.note_alt_sharp),
          ),
        ),
        onWillPop: () async {
          bool b = selectMode;
          if (selectMode) exitSelectMode();
          return !b;
        });
  }

  bool selectMode = false;

  Widget _buildList(BuildContext context) {
    keys.clear();

    tiles = _allFilesNames.map(
      (File f) {
        GlobalKey<MyListTileState> key = GlobalKey();
        keys.add(key);

        return new MyListTile(
          file: f,
          selectMode: selectMode,
          storage: widget.storage,
          function: updateChildren,
          key: key,
        );
      },
    );
    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(context: context, tiles: tiles).toList()
        : <Widget>[];
    return ListView(
      padding: const EdgeInsets.all(8),
      children: divided,
    );
  }

  void enterSelectMode() {
    setState(() {
      selectMode = true;
    });
  }

  void exitSelectMode() {
    setState(() {
      selectMode = false;
    });
  }

  void updateChildren() {
    enterSelectMode();
  }

  /* DROP DOWN MENUS*/
  DropdownButton btnAppBarMoreSelect() {
    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onChanged: (String? newValue) {
        switch (newValue) {
          case "Delete":
            keys.forEach((element) {
              element.currentState?.deleteFileFromSelect();
            });
            break;
          case "Cancel":
            exitSelectMode();
        }
        setState(() {});
      },
      underline: Container(color: Colors.transparent),
      items: <String>['Delete', 'Cancel']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  DropdownButton btnAppBarMoreNoSelect(BuildContext context) {
    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onChanged: (String? newValue) {
        switch (newValue) {
          case "Select":
            enterSelectMode();
            break;
          case "Settings":
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Settings(storage: widget.storage,)));
        }
        setState(() {});
      },
      underline: Container(color: Colors.transparent),
      items: <String>['Select', 'Settings']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
