import 'package:doctor/appointment_list_screen.dart';
import 'package:doctor/login_screen.dart';
import 'package:doctor/pending_appointments_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int touchedIndex = -1;
  int totalPatients = 0;
  int totalAppointments = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

    Future<void> fetchData() async {
      try {
        final patientResponse = await http.get(Uri.parse("http://127.0.0.1:8000/api/totalPatient"));
        final appointmentResponse = await http.get(Uri.parse("http://127.0.0.1:8000/api/totalAppointment"));

        if (patientResponse.statusCode == 200 && appointmentResponse.statusCode == 200) {
          final patientData = jsonDecode(patientResponse.body);
          final appointmentData = jsonDecode(appointmentResponse.body);
          setState(() {
            totalPatients = patientData["total_patients"];
            totalAppointments = appointmentData["total_appointment"];
          });
        }
      } catch (e) {
        print("Error fetching data: $e");
      }
    }
  void _logout() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear(); // Clears all stored session data

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to Login
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
            onPressed: _logout,
          ),
        ],
      ),
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
        _buildGlassmorphicCard("Total Patients", "$totalPatients", Icons.people, Colors.blue[300]!),
        _buildGlassmorphicCard("Today's Appointments", "$totalAppointments", Icons.event, Colors.purple[300]!),
      ],
    );
  }

  /// Soft Glassmorphic Card
  Widget _buildGlassmorphicCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(colors: [color.withOpacity(0.1), Colors.white]),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
              SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
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
            Text("Appointments Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
                swapAnimationDuration: Duration(milliseconds: 1600), // Smooth Animation
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
        radius: touchedIndex == 0 ? 55 : 50, // Expands on touch
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: 30,
        title: "Pending",
        color: Colors.orange[300],
        radius: touchedIndex == 1 ? 55 : 50, // Expands on touch
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  /// Approved & Pending Appointments List
  Widget _buildAppointmentsSection() {
    return Column(
      children: [
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
  Widget _buildAppointmentList(String title, List<String> appointments, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                if (title == "Pending Appointments") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PendingAppointmentsScreen()),
                  );
                }
                if (title == "Approved Appointments") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppointmentListScreen()),
                  );
                }
              },
              child: Column(
                children: appointments.map((appointment) {
                  return Card(
                    color: color.withOpacity(0.1),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(Icons.calendar_today, color: color),
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

}
