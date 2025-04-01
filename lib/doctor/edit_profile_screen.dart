
import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
      String? docId = prefs.getString('docId');

      if (docId == null) {
        print("Error: docId is missing.");
        _setLoading(false);
        return;
      }

      final response = await ApiService.post("getDoctorDetails", {"doctor_id": docId});

      if (response != null) {
        print(response);
        if (mounted) {
          setState(() {
            doctorDetails = response["doctor"];
            initializeControllers();
          });
        }
      } else {
        print("Failed to fetch doctor details.");
      }
    } catch (e) {
      print("Error fetching doctor details: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => isLoading = value);
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
      String? docId = prefs.getString('docId');

      final response = await ApiService.post(
        "updateDoctor",
        {
          "doctor_id": docId,
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text, // Password required
          "phone_number": phoneController.text,
          "address": addressController.text,
          "specialist": specialistController.text,
          "experience": experienceController.text,
        },
      );

      if (response != null) {
        _showMessage(response["message"], true);
      } else {
        _showMessage("Failed to update profile. Please try again.", false);
      }
    } catch (e) {
      _showMessage("Something went wrong. Please try again.", false);
      print("Exception: $e");
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
