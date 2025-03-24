import 'package:flutter/material.dart';

class StudentProfileUpdatePage extends StatefulWidget {
  @override
  _StudentProfileUpdatePageState createState() => _StudentProfileUpdatePageState();
}

class _StudentProfileUpdatePageState extends State<StudentProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, "Name"),
                _buildTextField(emailController, "Email", isEmail: true),
                _buildTextField(passwordController, "Password", isPassword: true),
                _buildTextField(mobileController, "Mobile", isNumber: true),
                // _buildGenderDropdown(),
                _buildTextField(ageController, "Age", isNumber: true),
                _buildTextField(addressController, "Address"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save data logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Profile Updated Successfully!")),
                      );
                    }
                  },
                  child: Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isEmail = false, bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
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

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: DropdownButtonFormField<String>(
        value: gender,
        decoration: InputDecoration(
          labelText: "Gender",
          border: OutlineInputBorder(),
        ),
        items: ["Male", "Female", "Other"].map((String category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            gender = value;
          });
        },
        validator: (value) => value == null ? "Please select gender" : null,
      ),
    );
  }
}
