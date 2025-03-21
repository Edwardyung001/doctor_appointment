import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:doctor/dashboard_screen.dart';
import 'package:doctor/doctor_registration_screen.dart';
import 'package:doctor/patient_registration_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? username, password;
  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("http://127.0.0.1:8000/api/login"); // Replace with your API URL
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": username,
        "password": password,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Successful! Welcome, ${data['name']}")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorDashboardScreen()),
      );
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
                  SizedBox(height: 30),
                  Center(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 8,
                      shadowColor: Colors.black26,
                      color: Colors.white.withOpacity(0.85),
                      child: Container(
                        width: 450,
                        padding: EdgeInsets.all(15),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTextField("Email", Icons.email, (val) => username = val),
                              _buildTextField("Password", Icons.lock, (val) => password = val, isPassword: true),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 250,
                                child: ElevatedButton(
                                  onPressed: () => login(context),
                                  child: isLoading
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    backgroundColor: Color(0xFF0080A2),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("Don't have an account?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildRegisterButton("Patient", Color(0xFFFC455D), Icons.local_hospital, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PatientRegistrationScreen()),
                                    );
                                  }),
                                  SizedBox(width: 8),
                                  _buildRegisterButton("Doctor", Colors.blue.shade600, Icons.medical_services, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DoctorRegistrationScreen()),
                                    );
                                  }),
                                ],
                              ),
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

  Widget _buildTextField(String label, IconData icon, Function(String) onChanged, {bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextFormField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.teal.shade900),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.teal.shade700),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "$label is required";
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRegisterButton(String text, Color color, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
