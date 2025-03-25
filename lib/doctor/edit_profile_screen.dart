import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isSaving = false;
  Map<String, dynamic>? doctorDetails;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  late TextEditingController ageController;
  late TextEditingController specialistController;
  late TextEditingController addressController;
  late TextEditingController experienceController;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  Future<void> fetchDoctorDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? docId = prefs.getString('docId');

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/getDoctorDetails"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"doctor_id": docId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          doctorDetails = data["doctor"];
          initializeControllers();
          isLoading = false;
        });
      } else {
        print("Error: ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching doctor details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void initializeControllers() {
    nameController = TextEditingController(text: doctorDetails?['name'] ?? '');
    emailController = TextEditingController(text: doctorDetails?['email'] ?? '');
    passwordController = TextEditingController();
    phoneController = TextEditingController(text: doctorDetails?['phone'] ?? '');
    ageController = TextEditingController(text: doctorDetails?['age']?.toString() ?? '');
    specialistController = TextEditingController(text: doctorDetails?['specialist'] ?? '');
    addressController = TextEditingController(text: doctorDetails?['address'] ?? '');
    experienceController = TextEditingController(text: doctorDetails?['experience']?.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    ageController.dispose();
    specialistController.dispose();
    addressController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? docId = prefs.getString('docId');

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/updateDoctor"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "doctor_id": docId,
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text, // Password required
          "phone_number": phoneController.text,
          "address": addressController.text,
          "specialist": specialistController.text,
          "experience": experienceController.text,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showMessage(responseData["message"], true);
      } else {
        _showMessage(responseData["message"], false);
      }
    } catch (e) {
      _showMessage("Something went wrong. Please try again.", false);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
    if (isSuccess) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextFormField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextFormField(controller: phoneController, decoration: InputDecoration(labelText: "Phone")),
              TextFormField(controller: ageController, decoration: InputDecoration(labelText: "Age")),
              TextFormField(controller: specialistController, decoration: InputDecoration(labelText: "Specialist")),
              TextFormField(controller: addressController, decoration: InputDecoration(labelText: "Address")),
              TextFormField(controller: experienceController, decoration: InputDecoration(labelText: "Experience")),
              SizedBox(height: 20),
              isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveProfile,
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
