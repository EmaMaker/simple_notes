import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/screens/note/note.dart';

class CounterStorage {
  Future<Directory> localDir() async {
    final dir = (await getApplicationDocumentsDirectory()).path.toString();
    final directory = Directory('$dir/notes');

    if (!(await directory.exists())) directory.create();
    return directory;
  }

  Future<String> _localPath() async {
    final dir = await localDir();
    return dir.path;
  }

  Future<List<File>> getAllFiles() async {
    try {
      List<File> files = [];
      final directory = await localDir();
      await directory.list().forEach((element) {
        files.add(File(element.path));
        // debugPrint("debugPrinting $element");
      });

      return files;
    } catch (e) {
      final e = Exception("Error");
      debugPrint(e.toString());
      throw (e);
    }
  }

  Future<File> saveNote(String name, String content) async {
    final dir = (await localDir()).path;

    File file = File('$dir/$name');
    debugPrint('Saving note in file: $name, content: $content');

    // Write the file
    return file.writeAsString('$content');
  }

  Future<String> getNote(String name) async {
    final dir = (await localDir()).path;

    File file = File('$dir/$name');
    return await file.readAsString();
  }

  Future<String> getNextFreeNameForString(String s) async {
    final dir = await _localPath();
    int i = 0;
    String name = '$s';
    File f = File('$dir/$name');
    while (await f.exists()) {
      i++;
      name = '$s-$i';
      f = File('$dir/$name');
    }

    return name;
  }

  void deleteNoteFromfile(File f) async {
    await f.delete();
  }

  void deleteNote(String noteName) async {
    final dir = await _localPath();
    await File('$dir/$noteName').delete();
  }

  void renameNote(String oldName, String newName) async {
    debugPrint("TODO: Rename note");
    String dir = await _localPath();
    File f = File('$dir/$oldName');
    f.rename('$dir/$newName');
  }

  void saveRename(String oldName, String content, String newName) async {
    await saveNote(oldName, content);
    renameNote(oldName, newName);
  }

// Note: Name of the note/filepath. If "" create a new note
  void openNote(BuildContext context, String note) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NewNote(note: note, storage: this,)));
  }
}
