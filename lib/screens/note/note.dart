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
  late TextEditingController _controllerNote;

  @override
  void initState() {
    super.initState();

    _controllerNote = TextEditingController();

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
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 55,
              title: InkWell(
                child: Text("$_title"),
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

  void _toPrevious() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(storage: widget.storage)));
  }

  void _save() {
    _changed = false;

    widget.storage.saveNote(_title, _controllerNote.text);

    setState(() {});
  }

  void _onChange(String s) {
    _changed = true;
    setState(() {});
  }

  @override
  void dispose() {
    _controllerNote.dispose();
    super.dispose();
  }
}
