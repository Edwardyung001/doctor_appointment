import 'package:doctor/doctor/patient_history.dart';
import 'package:doctor/login_screen.dart';
import 'package:doctor/doctor/pending_appointments_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'appointment_list_screen.dart';
import 'edit_profile_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int touchedIndex = -1;
  int totalPatients = 0;
  int totalAppointments = 0;
  Map<String, dynamic>? doctorDetails;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDoctorDetails();
  }

  Future<void> fetchDoctorDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? docId = prefs.getString('docId');


      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/getDoctorDetails"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"doctor_id": docId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          doctorDetails = data["doctor"];
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching doctor details: $e");
    }
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Retrieve token

      if (token == null) {
        print("Token not found. User not authenticated.");
        return;
      }

      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/totalPatient"),
        headers: {
          'Authorization': 'Bearer $token', // Include Bearer Token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalPatients = data["total_patients"];
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Remove token and role

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Doctor Dashboard", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () => logout(context),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatisticsRow(),
            SizedBox(height: 20),
            _buildAnimatedDonutChart(),
            SizedBox(height: 20),
            _buildAppointmentsSection(),
          ],
        ),
      ),
    );
  }

  /// Total Patients & Appointments Stats
  Widget _buildStatisticsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGlassmorphicCard("Total Patients", "$totalPatients", Icons.people,
            Colors.blue[300]!),
        _buildGlassmorphicCard(
            "Today's Appointments", "$totalAppointments", Icons.event,
            Colors.purple[300]!),
      ],
    );
  }

  /// Soft Glassmorphic Card
  Widget _buildGlassmorphicCard(String title, String value, IconData icon,
      Color color) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
                colors: [color.withOpacity(0.1), Colors.white]),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
              SizedBox(height: 5),
              Text(value, style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  /// Animated Donut Chart for Appointment Status
  Widget _buildAnimatedDonutChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Appointments Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: _buildPieChartSections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null || pieTouchResponse
                            .touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                ),
                swapAnimationDuration: Duration(milliseconds: 1600),
                // Smooth Animation
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pie Chart Sections with Animation
  List<PieChartSectionData> _buildPieChartSections() {
    return [
      PieChartSectionData(
        value: 70,
        title: "Approved",
        color: Colors.green[300],
        radius: touchedIndex == 0 ? 55 : 50,
        // Expands on touch
        titleStyle: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: 30,
        title: "Pending",
        color: Colors.orange[300],
        radius: touchedIndex == 1 ? 55 : 50,
        // Expands on touch
        titleStyle: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  /// Approved & Pending Appointments List
  Widget _buildAppointmentsSection() {
    return Column(
      children: [
        _buildAppointmentList("Patient History", [
          "Click to view Patient History",
        ], Colors.orange[300]!),
        _buildAppointmentList("Approved Appointments", [
          "Click to view Approved Appointments List",
        ], Colors.green[300]!),
        _buildAppointmentList("Pending Appointments", [
          "Click to view Pending Appointments List",
        ], Colors.orange[300]!),
      ],
    );
  }

  /// Soft Appointment List
  Widget _buildAppointmentList(String title, List<String> appointments,
      Color color) {
    IconData leadingIcon;

    // Assign different icons based on the title
    if (title == "Pending Appointments") {
      leadingIcon = Icons.access_time; // Clock icon for pending
    } else if (title == "Approved Appointments") {
      leadingIcon = Icons.check_circle; // Check icon for approved
    } else if (title == "Patient History") {
      leadingIcon = Icons.history; // History icon for patient history
    } else {
      leadingIcon = Icons.calendar_today; // Default icon
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                if (title == "Pending Appointments") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PendingAppointmentsScreen()),
                  );
                } else if (title == "Approved Appointments") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppointmentListScreen()),
                  );
                } else if (title == "Patient History") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PatientHistoryScreen()),
                  );
                }
              },
              child: Column(
                children: appointments.map((appointment) {
                  return Card(
                    color: color.withOpacity(0.1),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(leadingIcon, color: color),
                      // Different icons
                      title: Text(appointment, style: TextStyle(fontSize: 16)),
                      trailing: Icon(Icons.arrow_forward_ios, color: color),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            accountName: Text(doctorDetails?['name'] ?? 'Loading...'),
            accountEmail: Text(doctorDetails?['email'] ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                doctorDetails?['name']?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(fontSize: 30, color: Colors.blue),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Phone: ${doctorDetails?['phone'] ?? 'N/A'}"),
          ),
          ListTile(
            leading: Icon(Icons.cake),
            title: Text("Age: ${doctorDetails?['age'] ?? 'N/A'}"),
          ),
          ListTile(
            leading: Icon(Icons.business),
            title: Text("Specialist: ${doctorDetails?['specialist'] ?? 'N/A'}"),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Address: ${doctorDetails?['address'] ?? 'N/A'}"),
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text("Experience: ${doctorDetails?['experience']} years"),
          ),
          Divider(), // Adds a separation line
          ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: Text("Edit Profile", style: TextStyle(color: Colors.blue)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

}
