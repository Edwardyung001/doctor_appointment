import 'package:doctor/doctor/dashboard_screen.dart';
import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  Future<void> _addPatient() async {
    if (_formKey.currentState!.validate()) {
      final response = await ApiService.post("addPatient", {
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "phone_number": _phoneController.text,
        'inType':"2",
        "address": _addressController.text.isNotEmpty ? _addressController.text : null,
        "gender": _genderController.text.isNotEmpty ? _genderController.text : null,
        "age": _ageController.text.isNotEmpty ? _ageController.text : null,
      });

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"])),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorDashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Patient Data Not Stored")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Patient"), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Enter email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value!.isEmpty ? "Enter password" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                validator: (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address (Optional)"),
              ),
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(labelText: "Gender (Optional)"),
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: "Age (Optional)"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPatient,
                child: Text("Add Patient"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
