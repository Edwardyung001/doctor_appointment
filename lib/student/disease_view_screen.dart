import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiseaseTableScreen extends StatefulWidget {
  @override
  _DiseaseTableScreenState createState() => _DiseaseTableScreenState();
}

class _DiseaseTableScreenState extends State<DiseaseTableScreen> {
  List<Map<String, dynamic>> diseaseList = [];
  bool _isLoading = true;
  String _errorMessage = "";
  // Retrieve token

  final String apiUrl = "http://127.0.0.1:8000/api/diseases";


  @override
  void initState() {
    super.initState();
    _fetchDiseases();
  }

  Future<void> _fetchDiseases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          diseaseList = List<Map<String, dynamic>>.from(data["diseases"]);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = "You are not authenticated. Please provide a valid token.";
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load data. Try again later.";
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Error: $error";
        _isLoading = false;
      });
    }
  }

  void _editDisease(int index) {
    print("Edit clicked for ${diseaseList[index]['name']}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Disease Records"), backgroundColor: Colors.blue),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text("Sl. No", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Disease Name", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Symptoms", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Treatment", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Cases", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Notes", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: diseaseList.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> data = entry.value;

              return DataRow(cells: [
                DataCell(Text("${index + 1}")), // Auto increment Sl. No
                DataCell(Text(data["name"] ?? "N/A")),
                DataCell(Text(data["symptoms"] ?? "N/A")),
                DataCell(Text(data["treatment"] ?? "N/A")),
                DataCell(Text("${data["cases"] ?? "0"}")),
                DataCell(Text(data["notes"] ?? "N/A")),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editDisease(index),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
