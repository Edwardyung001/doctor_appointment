import 'package:doctor/doctor/patient_history.dart';
import 'package:doctor/login_screen.dart';
import 'package:doctor/doctor/pending_appointments_screen.dart';
import 'package:doctor/network/api_serivce.dart';
import 'package:doctor/doctor/disease_view_screen.dart';
import 'package:flutter/material.dart';


import 'package:shared_preferences/shared_preferences.dart';

import 'appointment_list_screen.dart';
import 'edit_profile_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  Map<String, dynamic>? doctorDetails;

  @override
  void initState() {
    super.initState();

    fetchDoctorDetails();
  }

  Future<void> fetchDoctorDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? docId = prefs.getString('docId');

      final response = await ApiService.post(
        "getDoctorDetails",
        {"doctor_id": docId},
      );

      if (response != null) {
        setState(() {
          doctorDetails = response["doctor"];
        });
      } else {
        print("Error fetching doctor details");
      }
    } catch (e) {
      print("Exception: $e");
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
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/image2.jpg", // Ensure this image exists in the assets folder
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Text(
            'welcome  ${ doctorDetails?['name'] ?? 'Loading...'} !',
              // "Welcome Back, $doctorName!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
        ]
      ),
    );
  }


  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurpleAccent),
            accountName: Text(
              doctorDetails?['name'] ?? 'Loading...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              doctorDetails?['email'] ?? '',
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("assets/images/doctor1.jpeg"),
              onBackgroundImageError: (_, __) => Icon(Icons.person, size: 50),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.deepPurple),
            title: Text("View Profile", style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),ListTile(
            leading: Icon(Icons.description, color: Colors.deepPurple),
            title: Text("Add Disease", style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiseaseTableScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: Colors.deepPurple),
            title: Text("View Patient History",
                style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientHistoryScreen()),
              );
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.medical_services, color: Colors.deepPurple),
          //   title: Text("Diagnosis", style: TextStyle(color: Colors.deepPurple)),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => EditProfileScreen()),
          //     );
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.history, color: Colors.deepPurple),
            title: Text("Appointment List", style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentListScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.pending_actions, color: Colors.deepPurple),
            title: Text("Pending appointments",
                style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PendingAppointmentsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.deepPurple),
            title: Text("Logout", style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
             logout(context);
            },
          ),
        ],
      ),
    );
  }
}
