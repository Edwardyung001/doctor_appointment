import 'package:flutter/material.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> disease;

  DiseaseDetailScreen({required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(disease["disease_name"] ?? "Disease Details"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Disease Name:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(disease["disease_name"] ?? "N/A", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Text("Symptoms:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(disease["symptoms"] ?? "N/A", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Text("Treatment:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(disease["treatment"] ?? "N/A", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Text("Causes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(disease["causes"] ?? "N/A", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Text("Overview:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(disease["overview"] ?? "N/A", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
