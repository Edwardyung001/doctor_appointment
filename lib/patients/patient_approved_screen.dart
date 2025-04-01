import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'prescription_details_screen.dart'; // Import the new screen

class PatientApprovedScreen extends StatefulWidget {
  @override
  _PatientApprovedScreenState createState() => _PatientApprovedScreenState();
}

class _PatientApprovedScreenState extends State<PatientApprovedScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchApprovedAppointments();
  }

  Future<void> fetchApprovedAppointments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? patientId = prefs.getString('docId');

    final response = await ApiService.post("patientApproved", {"patientId": patientId});

    if (response != null && response.containsKey('appointments')) {
      setState(() {
        appointments = List<Map<String, dynamic>>.from(response['appointments']);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = response?['message'] ?? "Failed to load data";
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approved Appointments"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      )
          : appointments.isEmpty
          ? Center(
        child: Text(
          "No approved appointments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          var appointment = appointments[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Doctor: ${appointment['doctor_name']}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Specialist: ${appointment['doctor_specialist']}"),
                  SizedBox(height: 5),
                  Divider(),
                  Text(
                    "Patient: ${appointment['patient_name']}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("Age: ${appointment['patient_age']}"),
                  Text("Problem: ${appointment['problem']}"),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date: ${appointment['appoint_date']}",
                        style: TextStyle(color: Colors.blue),
                      ),
                      Text(
                        "Time: ${appointment['appoint_time']}",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.receipt_long, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrescriptionDetailsScreen(
                              appointmentId: appointment['appointment_id'].toString(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
