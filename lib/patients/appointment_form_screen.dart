import 'package:doctor/patients/PatientsDashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentFormScreen extends StatefulWidget {
  @override
  _AppointmentFormScreenState createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController problemController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  List<Map<String, dynamic>> doctors = [];
  String? selectedDoctorId;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/doctors"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        doctors = List<Map<String, dynamic>>.from(data['doctors']);
      });
    } else {
      print("Failed to fetch doctors: ${response.body}");
    }
  }

  Future<void> createAppointment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? patientId = prefs.getString('docId');

    if (selectedDoctorId == null ||
        fullNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        problemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("All fields are required!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/createAppointment"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "patientId": patientId, // Replace with logged-in patient ID
        "doctorId": selectedDoctorId,
        "appointTime": timeController.text,
        "appointDate": dateController.text,
        "problem": problemController.text,
      }),
    );

    final data = jsonDecode(response.body);
print(data);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data["message"]),
        backgroundColor: Colors.green,
      ));
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PatientsDashboardScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data["message"]),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book an Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedDoctorId,
              decoration: InputDecoration(labelText: "Select Doctor", border: OutlineInputBorder()),
              items: doctors.map((doctor) {
                return DropdownMenuItem<String>(
                  value: doctor["doctor_id"].toString(),
                  child: Text(doctor["doctor_name"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDoctorId = value;
                });
              },
            ),
            SizedBox(height: 15),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: "Select Date", border: OutlineInputBorder()),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                }
              },
              readOnly: true,
            ),
            SizedBox(height: 15),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: "Select Time", border: OutlineInputBorder()),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  timeController.text = pickedTime.format(context);
                }
              },
              readOnly: true,
            ),
            SizedBox(height: 15),
            TextField(
              controller: problemController,
              decoration: InputDecoration(labelText: "Describe Your Problem", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: createAppointment,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
