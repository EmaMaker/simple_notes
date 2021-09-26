import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes_app/components/storage.dart';
import 'package:notes_app/screens/settings/settings.dart';

import 'package:path/path.dart';
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
  bool selectMode = false;
  String _sortBy = "";

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
                ? [btnAppBarMoreSelect(context)]
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
            child: Icon(Icons.edit),
          ),
        ),
        onWillPop: () async {
          bool b = selectMode;
          if (selectMode) exitSelectMode();
          return !b;
        });
  }

  Widget _buildList(BuildContext context) {
    sortFiles();
    final tiles = _allFilesNames.map(
      (
        File file,
      ) {
        return selectMode
            ? CheckboxListTile(
                title: Text(basename(file.path)),
                checkColor: Colors.white,
                value: _selected.contains(file.path),
                onChanged: (bool? value) {
                  toggleFile(file);
                })
            : ListTile(
                title: Text(
                  basename(file.path),
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () =>
                    widget.storage.openNote(context, basename(file.path)),
                onLongPress: () {
                  _selected.add(file.path);
                  enterSelectMode();
                },
                subtitle: _subtitle(file),
                trailing: btnListTileMore(context, file),
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

  /* --------------------------------------- UTILITY FUNCTIONS ------------------------------------------- */

  void sortFiles() {
    if (_sortBy == "Name") {
      _allFilesNames.sort((a, b) {
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });
    } else if (_sortBy == "Last Modified") {
      _allFilesNames.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
    }
  }

  Widget _subtitle(File f) {
    try {
      return Text(_lastEdited(f.lastModifiedSync()));
    } catch (e) {
      return Text("");
    }
  }

  String _lastEdited(DateTime now) {
    return "Last edited: ${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} at ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
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

  void toggleFile(File file) {
    if (_selected.contains(file.path))
      _selected.remove(file.path);
    else
      _selected.add(file.path);
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

  /* --------------------------------------- DROP DOWN MENUS ------------------------------------------- */
  /* APPBAR MORE (SELECT)*/
  DropdownButton btnAppBarMoreSelect(BuildContext context) {
    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert),
      onChanged: (String? newValue) {
        switch (newValue) {
          case "Delete Selected":
            _deleteAllDialog(context);
            break;
          case "Exit Select Mode":
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
        "Delete Selected",
        "Select All",
        "Deselect All",
        "Toggle Selected",
        "Exit Select Mode",
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
  /* --------------------- */

  /* APPBAR MORE (NO SELECT)*/
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

  /* TILE MORE */
  DropdownButton btnListTileMore(BuildContext context, File f) {
    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert_outlined),
      onChanged: (String? newValue) {
        switch (newValue) {
          case "Delete":
            _deleteSingleDialog(context, f);
            break;
          case "Rename":
            _changeTitleDialog(context, f.path);
            break;
        }
        setState(() {});
      },
      underline: Container(color: Colors.transparent),
      items: <String>['Rename', 'Delete']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
  /* --------------------- */

  /* --------------------------------------- DIALOGS ------------------------------------------- */
  /* RENAME DIALOG */
  void _changeTitleDialog(BuildContext context, String path) {
    // debugdebugPrint("Clicked title");
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Rename note:'),
            content: TextField(
              controller: _controller,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: basename(path),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    // Return to previous screen
                    Navigator.pop(context);
                    _controller.text = "";
                  },
                  child: Text('No')),
              TextButton(
                  onPressed: () {
                    if (_controller.text != "") {
                      Navigator.pop(context);
                      _selected.remove(path);
                      widget.storage
                          .renameNote(basename(path), _controller.text);
                      _controller.text = "";
                    }
                  },
                  child: Text('Yes')),
            ],
          );
        });
  }
  /* --------------------- */

  /* DELETE MULTIPLE DIALOG */
  void _deleteAllDialog(BuildContext context) {
    // debugdebugPrint("Clicked title");
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Delete notes'),
            content: Text(
                "Are you sure you want to delete the selected notes? This action cannot be undone!"),
            actions: [
              TextButton(
                  onPressed: () {
                    // Remove the box
                    // Return to previous screen
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //Return to previous screen
                    setState(() {});

                    _selected.forEach((element) {
                      File(element).deleteSync();
                    });
                    _selected.clear();
                  },
                  child: Text('Ok')),
            ],
          );
        });
  }
  /* --------------------- */

  /* DELETE SINGLE DIALOG */
  void _deleteSingleDialog(BuildContext context, File f) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Delete note'),
            content: Text(
                "Are you sure you want to delete this note? This action cannot be undone!"),
            actions: [
              TextButton(
                  onPressed: () {
                    // Remove the box
                    // Return to previous screen
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //Return to previous screen
                    setState(() {});
                    _deleteFile(f);
                  },
                  child: Text('Ok')),
            ],
          );
        });
  }
  /* --------------------- */
}
