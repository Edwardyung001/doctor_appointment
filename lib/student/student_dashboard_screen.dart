import 'package:doctor/login_screen.dart';
import 'package:doctor/doctor/disease_enter_screen.dart';
import 'package:doctor/network/api_serivce.dart';
import 'package:doctor/student/student_disease_view.dart';
import 'package:doctor/student/student_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../doctor/disease_view_screen.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? studentDetails;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentId = prefs.getString('docId');

    if (studentId == null) {
      print("Error: studentId is missing.");
      return;
    }

    try {
      final response = await ApiService.post("getProfile", {"student_id": studentId});

      if (response != null && response['status'] == true) {
        setState(() {
          studentDetails = response['student'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['message'] ?? "Failed to fetch profile")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching profile")),
      );
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
      appBar: AppBar(title: Text("Student Dashboard"), backgroundColor: Colors.purple),
      drawer: _buildDrawer(context), // Pass context to the drawer
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
            'welcome  ${ studentDetails ?['name'] ?? 'Loading...'} !',
              // "Welcome Back, $doctorName!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
        ]
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurpleAccent),
            accountName: Text(
              studentDetails?['name'] ?? 'Loading...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              studentDetails?['email'] ?? '',
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
                MaterialPageRoute(builder: (context) => StudentProfileUpdatePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, color: Colors.deepPurple),
            title: Text("View Disease", style: TextStyle(color: Colors.deepPurple)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudentDiseaseScreen()),
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
