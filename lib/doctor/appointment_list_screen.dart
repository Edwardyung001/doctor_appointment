import 'package:doctor/doctor/patient_details_screen.dart';
import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../patients/prescription_details_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<dynamic> appointments = [];
  List<dynamic> filteredAppointments = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAppointments();
    searchController.addListener(() => filterAppointments());
  }

  Future<void> fetchAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? docId = prefs.getString('docId');

      if (docId == null) {
        print("Error: docId is missing.");
        _setLoading(false);
        return;
      }

      final response = await ApiService.post("approvalAppointmentList", {"docId": docId});

      if (response != null) {
        print(response);
        if (mounted) {
          setState(() {
            appointments = response["appointments"] ?? [];
            filteredAppointments = List.from(appointments);
          });
        }
      } else {
        print("Failed to fetch appointments.");
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => isLoading = value);
  }


  void filterAppointments() {
    String query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredAppointments = List.from(appointments);
      });
      return;
    }

    List<dynamic> tempList = appointments.where((appointment) {
      return appointment["name"].toLowerCase().contains(query);
    }).toList();

    tempList.sort((a, b) {
      bool aMatches = a["name"].toLowerCase().startsWith(query);
      bool bMatches = b["name"].toLowerCase().startsWith(query);
      return (bMatches ? 1 : 0) - (aMatches ? 1 : 0);
    });

    setState(() {
      filteredAppointments = tempList;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approved Appointments"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Patient",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredAppointments.isEmpty
                ? Center(
              child: Text(
                "No data found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                var appointment = filteredAppointments[index];
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.receipt_long, color: Colors.blue), // Prescription Icon
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrescriptionDetailsScreen(
                                  appointmentId: appointment["appoint_id"].toString(),
                                ),
                              ),
                            );
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientDetailsScreen(
                                  appointmentId: appointment["appoint_id"].toString(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text("Diagnose"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
