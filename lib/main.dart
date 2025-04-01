import 'package:doctor/patients/PatientsDashboardScreen.dart';
import 'package:doctor/student/student_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor/dashboard_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> getHomeScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');

    if (token != null) {
      if (role == "doctor" || role=="Doctor") {
        return DoctorDashboardScreen();
      } else if (role == "patient" || role == "Patient") {
        return PatientsDashboardScreen();
      }
      else if (role == "student" || role == "Student") {
        return StudentDashboard();
      }
    }
    return LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: getHomeScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Error loading app")),
            );
          } else {
            return snapshot.data ?? LoginPage();
          }
        },
      ),
    );
  }
}
