import 'package:doctor/doctor/in_paitent_details_screen.dart';
import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';

class InPatientListScreen extends StatefulWidget {
  @override
  _InPatientListScreenState createState() => _InPatientListScreenState();
}

class _InPatientListScreenState extends State<InPatientListScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchInPatients();
  }

  Future<void> _fetchInPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final response = await ApiService.get("patients");

    if (response != null && response["patients"] != null) {
      setState(() {
        _patients = List<Map<String, dynamic>>.from(response["patients"]);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = "Failed to load patient data.";
        _isLoading = false;
      });
    }
  }

  void _navigateToPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("In-Patient List"), backgroundColor: Colors.blue),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
          : ListView.builder(
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  patient["name"][0].toUpperCase(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(patient["name"], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Age: ${patient["age"]}, Gender: ${patient["gender"]}"),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
              onTap: () => _navigateToPatientDetails(patient),
            ),
          );
        },
      ),
    );
  }
}
