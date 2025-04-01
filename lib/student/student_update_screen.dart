import 'dart:convert';
import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfileUpdatePage extends StatefulWidget {
  @override
  _StudentProfileUpdatePageState createState() => _StudentProfileUpdatePageState();
}

class _StudentProfileUpdatePageState extends State<StudentProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isEdited = false;
  bool _isSaving = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? gender;
  String apiUrl = "http://127.0.0.1:8000/api/getProfile";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _addListeners();
  }

  void _addListeners() {
    nameController.addListener(() => _onEdited());
    emailController.addListener(() => _onEdited());
    mobileController.addListener(() => _onEdited());
    ageController.addListener(() => _onEdited());
    addressController.addListener(() => _onEdited());
  }

  void _onEdited() {
    if (!_isEdited) {
      setState(() {
        _isEdited = true;
      });
    }
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentId = prefs.getString('docId');

    try {
      final response = await ApiService.post("getProfile", {"student_id": studentId});

      if (response != null && response['status'] == true) {
        final student = response['student'];
        setState(() {
          nameController.text = student['name'];
          emailController.text = student['email'];
          mobileController.text = student['phone'];
          ageController.text = student['age'].toString();
          addressController.text = student['address'];
          _isLoading = false;
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

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? studentId = prefs.getString('docId');

    final input = {
      "student_id": studentId,
      "name": nameController.text,
      "email": emailController.text,
      "phone": mobileController.text,
      "age": ageController.text,
      "address": addressController.text,
    };

    try {
      final response = await ApiService.post("updateStudent", input, token: token);

      if (response != null && response['status'] == true) {
        setState(() {
          _isEdited = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile Updated Successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['message'] ?? "Failed to update profile")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile")),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, "Name"),
                _buildTextField(emailController, "Email", isEmail: true),
                _buildTextField(mobileController, "Mobile", isNumber: true),
                _buildTextField(ageController, "Age", isNumber: true),
                _buildTextField(addressController, "Address"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isEdited && !_isSaving ? _saveChanges : null,
                  child: _isSaving ? CircularProgressIndicator() : Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isEmail = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$labelText is required";
          }
          if (isEmail && !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
            return "Enter a valid email";
          }
          return null;
        },
      ),
    );
  }
}
