import 'package:doctor/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientRegistrationScreen extends StatefulWidget {
  @override
  _PatientRegistrationScreenState createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name, email, password, age, gender, contact, address, problem;
  bool appointmentRequired = false;

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
                  SizedBox(
                    height: 150,
                    child: Image.asset('assets/images/LoginImage.jpg', fit: BoxFit.contain),
                  ),
                  SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 450),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Patient Registration",
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(height: 15),
                              _buildTextField("Name", (val) => name = val),
                              _buildTextField("Email", (val) => email = val, isEmail: true),
                              _buildTextField("Password", (val) => password = val, isPassword: true),
                              _buildTextField("Age", (val) => age = val, keyboardType: TextInputType.number),
                              _buildTextField("Gender", (val) => gender = val),
                              _buildTextField("Contact", (val) => contact = val, keyboardType: TextInputType.phone),
                              _buildTextField("Address", (val) => address = val),
                              _buildRadioButtons(),
                              _buildTextField("Problem Description", (val) => problem = val, maxLines: 3),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _submitForm,
                                child: Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.blueAccent,
                                  elevation: 4,
                                ),
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

  Widget _buildTextField(String label, Function(String) onChanged,
      {bool isPassword = false, bool isEmail = false, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: isEmail
              ? Icon(Icons.email, color: Colors.blueAccent)
              : isPassword
              ? Icon(Icons.lock, color: Colors.blueAccent)
              : null,
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "$label is required";
          if (isEmail && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(val)) return "Enter a valid email";
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appointment Required?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text("Yes"),
                leading: Radio<bool>(
                  value: true,
                  groupValue: appointmentRequired,
                  onChanged: (value) => setState(() => appointmentRequired = value!),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text("No"),
                leading: Radio<bool>(
                  value: false,
                  groupValue: appointmentRequired,
                  onChanged: (value) => setState(() => appointmentRequired = value!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/addPatient"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phone_number": contact,
          "address": address ?? "",
          "gender": gender ?? "",
          "age": age ?? "",
          "appointment_status": appointmentRequired ? "Yes" : "No",
          "problem": problem ?? "",
        }),
      );
print(response.body);
      if (response.statusCode == 200|| response.statusCode == 201) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Patient added successfully!")),
        );


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    }
  }
}