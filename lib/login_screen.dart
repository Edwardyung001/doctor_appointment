import 'dart:convert';
import 'package:doctor/network/api_serivce.dart';
import 'package:doctor/password_textfiled_widget.dart';
import 'package:doctor/patients/PatientsDashboardScreen.dart';
import 'package:doctor/student/student_dashboard_screen.dart';
import 'package:doctor/student/student_signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doctor/doctor/dashboard_screen.dart';
import 'package:doctor/doctor/doctor_registration_screen.dart';
import 'package:doctor/patients/patient_registration_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? username, password, selectedRole;
  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate() || selectedRole == null) return;

    setState(() => isLoading = true);

    // API request payload
    final requestBody = {
      "email": username,
      "password": password,
      "role": selectedRole!.toLowerCase(),
    };

    print("Sending request: $requestBody");

    // Use common API service
    final response = await ApiService.post("login", requestBody);

    setState(() => isLoading = false);

    if (response != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']);
      await prefs.setString('role', selectedRole!);
      await prefs.setString('docId', response['userId'].toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${response['message']}")),
      );

      // Navigate to the respective dashboard
      if (selectedRole!.toLowerCase() == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorDashboardScreen()),
        );
      } else if (selectedRole!.toLowerCase() == "patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientsDashboardScreen()),
        );
      } else if (selectedRole!.toLowerCase() == "student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid credentials. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to MedCare",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 8,
                      shadowColor: Colors.black26,
                      color: Colors.white.withOpacity(0.85),
                      child: Container(
                        width: 450,
                        padding: const EdgeInsets.all(15),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextField(
                                label: "Email",
                                icon: Icons.email,
                                onChanged: (val) => username = val,
                              ),
                              CustomTextField(
                                label: "Password",
                                icon: Icons.lock,
                                onChanged: (val) => password = val,
                                isPassword: true, // Enable password visibility toggle
                              ),
                              _buildRoleDropdown(),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 250,
                                child: ElevatedButton(
                                  onPressed: () => login(context),
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    backgroundColor: const Color(0xFF0080A2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text("Don't have an account?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildRegisterButton("Patient", const Color(0xFFFC455D), Icons.local_hospital, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PatientRegistrationScreen()),
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  _buildRegisterButton("Doctor", Colors.blue.shade600, Icons.medical_services, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DoctorRegistrationScreen()),
                                    );
                                  }),

                                ],
                              ),
                              const SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  _buildRegisterButton("Student", Colors.green.shade600, Icons.account_circle, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => StudentSignupScreen()),
                                    );
                                  }),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: InputDecoration(
          labelText: "Select Role",
          labelStyle: TextStyle(color: Colors.teal.shade900),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.person, color: Colors.teal.shade700),
        ),
        items: ["Doctor", "Patient","Student"].map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(role),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            selectedRole = val!;
          });
        },
        validator: (val) => val == null ? "Role is required" : null,
      ),
    );
  }

  Widget _buildRegisterButton(String text, Color color, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
