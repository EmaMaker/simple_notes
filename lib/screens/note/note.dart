import 'package:flutter/material.dart';
import 'package:notes_app/components/storage.dart';
import 'package:notes_app/screens/home/home.dart';

class NewNote extends StatefulWidget {
  const NewNote({Key? key, required this.note, required this.storage})
      : super(key: key);
  final String note;
  final CounterStorage storage;

  @override
  _NewNoteState createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  bool _changed = false;
  String _title = "New Note";
  late TextEditingController _controllerNote, _controller;

  @override
  void initState() {
    super.initState();

    _controllerNote = TextEditingController();
    _controller = TextEditingController();

    if (widget.note != "") {
      widget.storage.getNote(widget.note).then((String value) {
        setState(() {
          _controllerNote.text = value;
        });
      });
      _title = widget.note;
    } else {
      // Get increasing indeces after title, if a note with the same title already exists
      widget.storage.getNextFreeNameForString(_title).then((String value) {
        setState(() {
          _title = value;
          debugPrint(_title);
        });
      });
    }
  }

  @override
  void dispose() {
    _controllerNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              title: InkWell(
                child: Text("$_title"),
                onTap: () => _changeTitleDialog(context),
              ),
              centerTitle: true,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () => _deleteDialog(context),
              ),
              actions: [
                if (_changed)
                  new IconButton(
                      onPressed: () => _save(), icon: new Icon(Icons.save))
              ],
            ),
            body: Center(
                child: TextField(
              onChanged: _onChange,
              autocorrect: true,
              enableInteractiveSelection: true,
              enableSuggestions: true,
              maxLines: 10000,
              controller: _controllerNote,
              decoration: const InputDecoration(
                  hintText: 'Type your new note here',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 16)),
            ))),
        onWillPop: () async {
          _deleteDialog(context);
          return true;
        });
  }

  /* --------------------------------------- DIALOGS ------------------------------------------- */
  /* RENAME DIALOG */
  void _changeTitleDialog(BuildContext context) {
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
                hintText: _title,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                      _controller.text = "";
                    });
                  },
                  child: Text('No')),
              TextButton(
                  onPressed: () {
                    if (_controller.text != "") {
                      setState(() {
                        Navigator.pop(context);
                        //Note: code repetition
                        if (_title != _controller.text) {
                          _save(rename: true, newname: _controller.text);

                          _controller.text = "";
                        }
                      });
                    }
                  },
                  child: Text('Yes')),
            ],
          );
        });
  }
  /* --------------------- */

  /* DELETE DIALOG */
  void _deleteDialog(BuildContext context) {
    if (_changed)
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text('Please Confirm'),
              content: Text('Do you want to save the note?'),
              actions: [
                // The "Yes" button
                TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.pop(context);
                      // Remove the box
                      setState(() {});
                      debugPrint('Don\'t save the note');

                      // Return to previous screen
                      _toPrevious();
                    },
                    child: Text('No')),
                TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.pop(context);
                      _save();
                      setState(() {});
                      debugPrint('Save the note');

                      //Return to previous screen
                      _toPrevious();
                    },
                    child: Text('Yes'))
              ],
            );
          });
    else
      _toPrevious();
  }
  /* --------------------- */

  /* --------------------------------------- UTILITY FUNCTIONS ------------------------------------------- */
  void _toPrevious() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(storage: widget.storage)));
  }

  void _save({bool rename = false, String newname = ""}) {
    setState(() {
      _changed = false;
      if (rename) {
        widget.storage.saveRename(_title, _controllerNote.text, newname);
        _title = newname;
      } else
        widget.storage.saveNote(_title, _controllerNote.text);
    });
  }

  void _onChange(String s) {
    setState(() {
      _changed = true;
    });
  }
}
