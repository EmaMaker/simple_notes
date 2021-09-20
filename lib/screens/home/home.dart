import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes_app/components/storage.dart';
import 'package:notes_app/screens/home/components/MyListTile.dart';
import 'package:notes_app/screens/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.storage}) : super(key: key);
  final CounterStorage storage;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<File> _allFilesNames = [];
  List<String> _selected = [];

  String _sortBy = "";

  @override
  void initState() {
    super.initState();
  }

  void getSortBy() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortBy = prefs.getString("sortBy") ?? "Name";
    });
  }

  @override
  Widget build(BuildContext context) {
    getSortBy();

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
            child: Icon(Icons.add),
          ),
        ),
        onWillPop: () async {
          bool b = selectMode;
          if (selectMode) exitSelectMode();
          return !b;
        });
  }

  bool selectMode = false;

  void sortFiles() {
    if (_sortBy == "Name") {
      _allFilesNames.sort((a, b) {
        return a.path.compareTo(b.path);
      });
    } else if (_sortBy == "Last Modified") {

      _allFilesNames.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
    }
  }

  Widget _buildList(BuildContext context) {
    sortFiles();
    final tiles = _allFilesNames.map(
      (
        File f,
      ) {
        return new MyListTile(
            file: f,
            selectMode: selectMode,
            storage: widget.storage,
            selectFunction: enterSelectMode,
            updateFunction: updateChildren,
            toggleFunction: toggleFile,
            deleteFunction: _deleteFile,
            isChecked: _selected.contains(f.path));
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
      _selected.clear();
      selectMode = false;
    });
  }

  void updateChildren() {
    setState(() {});
  }

  void toggleFile(File f, bool b) {
    if (_selected.contains(f.path))
      _selected.remove(f.path);
    else
      _selected.add(f.path);
    setState(() {});
  }

  void _deleteFile(File f) {
    setState(() {
      _selected.clear();
      try {
        f.deleteSync();
      } catch (e) {}
    });
    exitSelectMode();
  }

  /* DROP DOWN MENUS*/
  DropdownButton btnAppBarMoreSelect() {
    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert),
      onChanged: (String? newValue) {
        switch (newValue) {
          case "Delete":
            _selected.forEach((element) {
              File(element).deleteSync();
            });
            _selected.clear();

            exitSelectMode();
            break;
          case "Cancel":
            exitSelectMode();
            break;
          case "Select All":
            _selected.clear();
            _allFilesNames.forEach((element) {
              _selected.add(element.path);
            });
            break;
          case "Deselect All":
            _selected.clear();
            break;
          case "Toggle Selected":
            List<String> newSelected = [];

            _allFilesNames.forEach((element) {
              if (!(_selected.contains(element.path)))
                newSelected.add(element.path);
            });
            print("new $newSelected");
            _selected = newSelected;

            // keys.forEach((element) {element.currentState?.isChecked = !(element.currentState?.isChecked) ;});
            break;
        }
        setState(() {});
      },
      underline: Container(color: Colors.transparent),
      items: <String>[
        "Delete",
        "Select All",
        "Deselect All",
        "Toggle Selected",
        "Cancel",
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  DropdownButton btnAppBarMoreNoSelect(BuildContext context) {
    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert),
      onChanged: (String? newValue) {
        switch (newValue) {
          case "Select":
            if (_allFilesNames.isNotEmpty) enterSelectMode();
            break;
          case "Settings":
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Settings(
                          storage: widget.storage,
                        )));
        }
        setState(() {});
      },
      underline: Container(color: Colors.transparent),
      items: <String>['Settings', 'Select']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
