import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentNotesScreen extends StatefulWidget {
  @override
  _StudentNotesScreenState createState() => _StudentNotesScreenState();
}

class _StudentNotesScreenState extends State<StudentNotesScreen> {
  TextEditingController _noteController = TextEditingController();
  String _savedNote = "";

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  // Load saved note from local storage
  Future<void> _loadNote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNote = prefs.getString("saved_note") ?? "";
      _noteController.text = _savedNote;
    });
  }

  // Save note to local storage
  Future<void> _saveNote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("saved_note", _noteController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Note Saved Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notepad"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _noteController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: "Start writing your notes...",
            border: OutlineInputBorder(),
          ),
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
