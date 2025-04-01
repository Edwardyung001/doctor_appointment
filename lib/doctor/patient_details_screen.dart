import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';


class PatientDetailsScreen extends StatefulWidget {
  final String appointmentId;

  PatientDetailsScreen({required this.appointmentId});

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, dynamic>? appointment;
  bool isLoading = true;
  String errorMessage = "";
  TextEditingController notesController = TextEditingController();
  List<dynamic> diseases = [];

  @override
  void initState() {
    super.initState();
    fetchPrescriptionDetails();
  }

  Future<void> fetchPrescriptionDetails() async {
    try {
      final response = await ApiService.post(
        "getPatientDeatils",
        {"appointmentId": widget.appointmentId},
      );

      if (response != null && response.containsKey('appointment')) {
        setState(() {
          appointment = response['appointment'] ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response?["message"] ?? "No appointment details found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  Future<void> submitNotes() async {
    try {
      final response = await ApiService.post(
        "diseases/search",
        {"symptoms": notesController.text},
      );

      if (response != null && response.containsKey("diseases")) {
        setState(() {
          diseases = response["diseases"];
        });
      } else {
        setState(() {
          diseases = [];
          errorMessage = response?["message"] ?? "No diseases found.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
      });
    }
  }


  Widget buildInfoCard(IconData icon, String label, String? value) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? "N/A", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Details"), backgroundColor: Colors.blueAccent),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildInfoCard(Icons.person, "Name", appointment?["patient_name"].toString()),
              buildInfoCard(Icons.email, "Email", appointment?["patient_email"].toString()),
              buildInfoCard(Icons.phone, "Phone", appointment?["patient_phone"].toString()),
              buildInfoCard(Icons.wc, "Gender", appointment?["patient_gender"].toString()),
              buildInfoCard(Icons.cake, "Age", appointment?["patient_age"].toString()),
              buildInfoCard(Icons.local_hospital_outlined, "Problem", appointment?["problem"].toString()),
              Divider(thickness: 1, color: Colors.grey),
              Text("Doctor Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              buildInfoCard(Icons.person, "Doctor Name", appointment?["doctor_name"].toString()),
              buildInfoCard(Icons.email, "Doctor Email", appointment?["doctor_email"].toString()),
              buildInfoCard(Icons.phone, "Doctor Phone", appointment?["doctor_phone"].toString()),
              buildInfoCard(Icons.medical_services, "Specialist", appointment?["doctor_specialist"].toString()),
              buildInfoCard(Icons.star, "Experience", appointment?["doctor_experience"].toString()),

              // TextField for entering symptoms
              SizedBox(height: 20),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: "Enter Symptoms",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: submitNotes,
                child: Text("Submit Symptoms"),
              ),

              // Display diseases if found
              if (diseases.isNotEmpty) ...[
                SizedBox(height: 20),
                Text("Diseases Found:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...diseases.map((disease) => Card(
                  child: ListTile(
                    title: Text(disease["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Symptoms: ${disease["symptoms"]}"),
                        Text("Treatment: ${disease["treatment"]}"),
                        Text("Cases: ${disease["cases"]}"),
                        Text("Notes: ${disease["notes"]}"),
                        Text("Days: ${disease["day"]}"),
                      ],
                    ),
                  ),
                )),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
