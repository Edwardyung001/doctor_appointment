import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorRegistrationScreen extends StatefulWidget {
  @override
  _DoctorRegistrationScreenState createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name, email, password, specialization, experience, contact, address;

  /// **Submit Form & Call API**
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.parse("http://127.0.0.1:8000/api/addDoctor");
      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": name,
            "email": email,
            "password": password,
            "phone_number": contact,
            "address": address,
            "specialist": specialization,
            "experience": experience,
          }),
        );
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["message"] ?? "Doctor added successfully!")),
          );

          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context); // Ensure route is defined in MaterialApp
          });
        } else {
          // Show specific error message from API response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["error"] ?? "Failed to register. Please try again!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
        print(e);
      }
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
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Doctor Registration",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue, shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black26)
                      ]),
                    ),
                    SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTextField("Name", (val) => name = val),
                                _buildTextField("Email", (val) => email = val, isEmail: true),
                                _buildTextField("Password", (val) => password = val, isPassword: true),
                                _buildTextField("Specialization", (val) => specialization = val),
                                _buildTextField("Experience (Years)", (val) => experience = val, isNumeric: true),
                                _buildTextField("Contact Number", (val) => contact = val, isNumeric: true),
                                _buildTextField("Address", (val) => address = val),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _submitForm,
                                  child: Text("Register", style: TextStyle(fontSize: 18)),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    backgroundColor: Colors.blueAccent,
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
          ),
        ],
      ),
    );
  }

  /// **Reusable TextField**
  Widget _buildTextField(String label, Function(String) onChanged,
      {bool isPassword = false, bool isEmail = false, bool isNumeric = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return "$label is required";
          }
          if (isEmail && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(val)) {
            return "Enter a valid email";
          }
         
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}