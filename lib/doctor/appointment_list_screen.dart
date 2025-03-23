import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<dynamic> appointments = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? docId = prefs.getString('docId');

      if (token == null || docId == null) {
        print("Token or docId is missing.");
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/approvalAppointmentList"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"docId": docId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (mounted) {
          setState(() {
            appointments = data["appointments"];
            isLoading = false;
          });
        }
      } else {
        print("Failed to load appointments: ${response.body}");
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("Error fetching appointments: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approved Appointments"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : appointments.isEmpty
          ? Center(
        child: Text(
          "No data found",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
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
                  Text("Date: ${appointment["appoint_date"]}"),
                  Text("Time: ${appointment["appoint_time"]}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
