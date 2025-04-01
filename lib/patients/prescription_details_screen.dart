import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  final String appointmentId;

  PrescriptionDetailsScreen({required this.appointmentId});

  @override
  _PrescriptionDetailsScreenState createState() => _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  Map<String, dynamic>? appointment;
  List<dynamic> medicines = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPrescriptionDetails();
  }

  Future<void> fetchPrescriptionDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.post(
      "getPatientDeatils",
      {"appointmentId": widget.appointmentId},
    );

    if (response != null) {
      setState(() {
        appointment = response['appointment'];
        medicines = response['medicines'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = "Failed to fetch prescription details";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prescription Details"), backgroundColor: Colors.blue),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
          : appointment == null
          ? Center(child: Text("No prescription details available"))
          : Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Doctor: ${appointment!['doctor_name']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Specialist: ${appointment!['doctor_specialist']}"),
              SizedBox(height: 10),
              Text("Patient: ${appointment!['patient_name']}"),
              Text("Age: ${appointment!['patient_age']}"),
              Text("Problem: ${appointment!['problem']}"),
              SizedBox(height: 10),
              Divider(),
              medicines.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Medicines", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  for (var med in medicines)
                    Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(med['medicine']['name']),
                        subtitle: Text(
                          "Morning: ${med['morning']} | Afternoon: ${med['afternoon']} | Night: ${med['night']}\n"
                              "Duration: ${med['duration']}",
                        ),
                        trailing: Text(med['bm_am'], style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              )
                  : Center(child: Text("No medicines prescribed")),
            ],
          ),
        ),
      ),
    );
  }
}
