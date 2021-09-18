import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes_app/components/storage.dart';

import 'package:path/path.dart';
import 'dart:io';

class MyListTile extends StatefulWidget {
  MyListTile(
      {Key? key,
      required this.file,
      required this.storage,
      required this.function,
      required this.selectMode})
      : super(key: key);
  final File file;
  final CounterStorage storage;
  final Function function;
  final bool selectMode;

  @override
  MyListTileState createState() => MyListTileState();
}

class MyListTileState extends State<MyListTile> {
  final _biggerFont = const TextStyle(fontSize: 18);
  late TextEditingController _controller;

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Recreating cards");

    return widget.selectMode
        ? CheckboxListTile(
                title: Text(basename(widget.file.path)),
                checkColor: Colors.white,
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = widget.selectMode && value!;
                  });
                })
        : ListTile(
            title: Text(
              basename(widget.file.path),
              style: _biggerFont,
            ),
            onTap: () =>
                widget.storage.openNote(context, basename(widget.file.path)),
            onLongPress: () => widget.function,
            // onTap: _handleNote,
            subtitle: _subtitle(widget.file),
            trailing: btnListTileMore(context, widget.file),
          );
  }

  DropdownButton btnListTileMore(BuildContext context, File f) {
    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert_outlined),
      onChanged: (String? newValue) {
        switch (newValue) {
          case "Delete":
            _deleteDialog(context, f);
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

  /* DIALOGS */
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
                    setState(() {});
                    widget.function();

                    // Remove the box
                  },
                  child: Text('No')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.storage.renameNote(
                        basename(widget.file.path), _controller.text);
                    setState(() {});
                    widget.function();
                  },
                  child: Text('Yes')),
            ],
          );
        });
  }

  void _deleteDialog(BuildContext context, File f) {
    // debugdebugPrint("Clicked title");
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
                    _controller.text = "";
                    setState(() {});
                    widget.function();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    deleteFile();
                    Navigator.pop(context);
                    //Return to previous screen
                    setState(() {});
                    widget.function();
                  },
                  child: Text('Ok')),
            ],
          );
        });
  }

  Widget _subtitle(File f) {
    try {
      return Text(_lastEdited(f.lastModifiedSync()));
    } catch (e) {
      return Text("");
    }
  }

  String _lastEdited(DateTime now) {
    return "Last edited: ${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  void deleteFileFromSelect() {
    if (isChecked) deleteFile();
  }

  void deleteFile() {
    widget.file.deleteSync();
  }
}
