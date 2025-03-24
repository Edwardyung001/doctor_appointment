import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  @override
  _PendingAppointmentsScreenState createState() => _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  List<dynamic> pendingAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingAppointments();
  }

  Future<void> fetchPendingAppointments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? docId = prefs.getString('docId');
    String? token = prefs.getString('token');

    if (docId == null) {
      showSnackBar("Doctor ID not found!");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/newAppointmentList"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"docId": docId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("API Response: ${response.body}");
        setState(() {
          pendingAppointments = data["appointments"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        showSnackBar("Failed to fetch appointments.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showSnackBar("Error: $e");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> approveAppointment(int appointmentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    print(appointmentId);

    if (token == null) {
      showSnackBar("Authentication token not found. Please login again.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/approvalAppointment"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"appointmentId": appointmentId}),
      );

      final responseData = jsonDecode(response.body);
      print("API Response: ${response.body}"); // Debugging response

      if (response.statusCode == 200) {
        showSnackBar(responseData["message"]);
        fetchPendingAppointments(); // Refresh the list after approval
      } else if (response.statusCode == 401) {
        showSnackBar("Authentication error: ${responseData["message"]}");
      } else {
        showSnackBar("Error: ${responseData["message"]}");
      }
    } catch (e) {
      showSnackBar("Network error: $e");
      print(e);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Pending Appointments", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pendingAppointments.isEmpty
          ? Center(child: Text("No pending appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: pendingAppointments.length,
        itemBuilder: (context, index) {
          final appointment = pendingAppointments[index];

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 3,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text(
                      appointment["name"] ?? "Unknown",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(height: 20, color: Colors.grey[300]),
                infoRow("Email", appointment["email"] ?? "N/A"),
                infoRow("Phone", appointment["phone"] ?? "N/A"),
                infoRow("Problem", appointment["problem"] ?? "N/A"),
                infoRow("Gender", appointment["gender"] ?? "N/A"),
                infoRow("Age", appointment["age"]?.toString() ?? "N/A"),
                infoRow("Address", appointment["address"] ?? "N/A"),
                infoRow("Date", appointment["appoint_date"] ?? "N/A"),
                infoRow("Time", appointment["appoint_date"] ?? "N/A"),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => approveAppointment(appointment["appoint_id"]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Approve", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.deepPurple),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "$title: $value",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
