import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  PatientDetailsScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${patient["name"]}'s Details"), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Name", patient["name"]),
                _buildDetailRow("Email", patient["email"]),
                _buildDetailRow("Phone", patient["phone"]),
                _buildDetailRow("Age", patient["age"].toString()),
                _buildDetailRow("Gender", patient["gender"]),
                _buildDetailRow("Address", patient["address"] ?? "N/A"),
                // _buildDetailRow("Admission Type", patient["in_type"].toString()),
                // _buildDetailRow("Created At", patient["created_at"]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}
