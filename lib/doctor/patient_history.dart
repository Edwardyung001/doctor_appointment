import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PatientHistoryScreen extends StatefulWidget {
  @override
  _PatientHistoryScreenState createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  List<dynamic> appointments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPatientHistory();
  }

  Future<void> fetchPatientHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? docId = prefs.getString('docId');

      if (token == null || docId == null) {
        setState(() {
          errorMessage = "Authentication details missing.";
          isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/patientHistory"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"docId": docId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          appointments = data["appointments"];
          isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data["message"] ?? "Failed to load data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient History")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
          : appointments.isEmpty
          ? Center(child: Text("No patient history found."))
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          var patient = appointments[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text(patient['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Problem: ${patient['problem']}\nDate: ${patient['appoint_date']}"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to patient details page (if needed)
              },
            ),
          );
        },
      ),
    );
  }
}
