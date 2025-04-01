import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../login_screen.dart';



class StudentSignupScreen extends StatefulWidget {
  @override
  _StudentSignupScreenState createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;

  // Function to handle student signup
  Future<void> _signupStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final input = {
      "name": _nameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "phone_number": _mobileController.text,
      "gender": _selectedGender,
      "address": _addressController.text.isEmpty ? null : _addressController.text,
      "age": _ageController.text,
    };

    try {
      final response = await ApiService.post("addStudent", input);

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Signup successful!")),
        );

        if (response["message"] == "Student added successfully!" && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed. Please try again.")),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Signup"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Full Name", Icons.person, _nameController),
              _buildTextField("Email", Icons.email, _emailController, isEmail: true),
              _buildTextField("Password", Icons.lock, _passwordController, isPassword: true),
              _buildTextField("Mobile Number", Icons.phone, _mobileController, isNumber: true),
              _buildDropdownField("Gender", Icons.wc),
              _buildTextField("Age", Icons.cake, _ageController, isNumber: true),
              _buildTextField("Address", Icons.location_on, _addressController),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _signupStudent,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Sign Up", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build text fields
  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {bool isPassword = false, bool isEmail = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "$label is required";
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
          if (isNumber && !RegExp(r'^[0-9]+$').hasMatch(value)) return "Enter a valid number";
          if (isPassword && value.length < 6) return "Password must be at least 6 characters";
          return null;
        },
      ),
    );
  }

  // Function to build dropdown fields
  Widget _buildDropdownField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: ["Male", "Female", "Other"].map((String gender) {
          return DropdownMenuItem(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) => value == null ? "Please select gender" : null,
      ),
    );
  }
}
