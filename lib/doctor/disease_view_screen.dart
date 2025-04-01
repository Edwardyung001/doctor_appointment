import 'dart:convert';
import 'package:doctor/network/api_serivce.dart';
import 'package:doctor/doctor/disease_enter_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_disease.dart';

class DiseaseTableScreen extends StatefulWidget {
  @override
  _DiseaseTableScreenState createState() => _DiseaseTableScreenState();
}

class _DiseaseTableScreenState extends State<DiseaseTableScreen> {
  List<Map<String, dynamic>> diseaseList = [];
  bool _isLoading = true;
  String _errorMessage = "";

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

    final response = await ApiService.get("diseases");

    if (response != null) {
      setState(() {
        diseaseList = List<Map<String, dynamic>>.from(response["diseases"]);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = "Failed to load data. Try again later.";
        _isLoading = false;
      });
    }
  }

  void _editDisease(int index) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiseaseScreen(diseaseId: index),
      ),
    );
  }

  void _addDisease() {
   Navigator.push(context, MaterialPageRoute(builder: (context)=>DiseaseManagementPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Disease Records"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _addDisease,
              child: Text("Add Disease"),
            ),
            SizedBox(height: 10), // Spacing between button and table
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
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
                        DataCell(Text(data["disease_name"] ?? "N/A")),
                        DataCell(Text(data["symptoms"] ?? "N/A")),
                        DataCell(Text(data["treatment"] ?? "N/A")),
                        DataCell(Text("${data["causes"] ?? "N/A"}")),
                        DataCell(Text(data["overview"] ?? "N/A")),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editDisease(data['id']),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
