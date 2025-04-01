import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
      String? docId = prefs.getString('docId');

      if (docId == null) {
        setState(() {
          errorMessage = "Doctor ID is missing.";
          isLoading = false;
        });
        return;
      }

      final response = await ApiService.post("patientHistory", {"docId": docId});

      if (response != null && response.containsKey("appointments")) {
        setState(() {
          appointments = response["appointments"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response?["message"] ?? "Failed to load data.";
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
