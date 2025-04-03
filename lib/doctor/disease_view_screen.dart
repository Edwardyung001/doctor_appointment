import 'package:doctor/network/api_serivce.dart';
import 'package:doctor/doctor/disease_enter_screen.dart';
import 'package:flutter/material.dart';

import 'edit_disease.dart';

class DiseaseTableScreen extends StatefulWidget {
  @override
  _DiseaseTableScreenState createState() => _DiseaseTableScreenState();
}

class _DiseaseTableScreenState extends State<DiseaseTableScreen> {
  List<Map<String, dynamic>> diseaseList = [];
  List<Map<String, dynamic>> _filteredDiseaseList = [];
  bool _isLoading = true;
  String _errorMessage = "";
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDiseases();
    _searchController.addListener(_filterDiseases);
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
        _filteredDiseaseList = diseaseList;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = "Failed to load data. Try again later.";
        _isLoading = false;
      });
    }
  }

  void _filterDiseases() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDiseaseList = diseaseList
          .where((disease) =>
      (disease["disease_name"]?.toLowerCase() ?? "").contains(query) ||
          (disease["symptoms"]?.toLowerCase() ?? "").contains(query) ||
          (disease["treatment"]?.toLowerCase() ?? "").contains(query))
          .toList();
    });
  }

  void _editDisease(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiseaseScreen(diseaseId: index),
      ),
    );
  }

  void _addDisease() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DiseaseManagementPage()));
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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Diseases...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: _addDisease,
              child: Text("Add Disease"),
            ),
            SizedBox(height: 10),
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
                      DataColumn(label: Text("causes", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("overview", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _filteredDiseaseList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> data = entry.value;

                      return DataRow(cells: [
                        DataCell(Text("${index + 1}")),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
