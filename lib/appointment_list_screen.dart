import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<dynamic> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/api/approvalAppointmentList"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          appointments = data["appointments"];
        });
      } else {
        print("Failed to load appointments");
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approved Appointments"),
        backgroundColor: Colors.green,
      ),
      body: appointments.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          var appointment = appointments[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              title: Text(appointment["name"]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email: ${appointment["email"]}"),
                  Text("Date: ${appointment["appointment_date_time"]}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
