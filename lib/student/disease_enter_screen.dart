import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiseaseManagementPage extends StatefulWidget {
  @override
  _DiseaseManagementPageState createState() => _DiseaseManagementPageState();
}

class _DiseaseManagementPageState extends State<DiseaseManagementPage> {
  final _formKey = GlobalKey<FormState>();
  String diseaseName = '';
  String symptoms = '';
  String treatment = '';
  String cases = '';
  String notes = '';
  String day = '';
  List<dynamic> diseases = [];

  String apiUrl = "http://127.0.0.1:8000/api/diseases";

  Future<void> addDisease() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final newDisease = {
      "name": diseaseName,
      "symptoms": symptoms,
      "treatment": treatment,
      "cases": cases,
      "notes": notes,
      "day": day,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newDisease),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          diseases.add(responseData['disease']);
        });
        _formKey.currentState!.reset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Disease added successfully!")));
      } else {
        print("Failed to add disease: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Delete a disease (optional)
  void _deleteDisease(int index) {
    setState(() {
      diseases.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Disease Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Disease Name'),
                    validator: (value) => value!.isEmpty ? 'Enter a disease name' : null,
                    onSaved: (value) => diseaseName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Symptoms'),
                    validator: (value) => value!.isEmpty ? 'Enter symptoms' : null,
                    onSaved: (value) => symptoms = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Treatment'),
                    validator: (value) => value!.isEmpty ? 'Enter treatment' : null,
                    onSaved: (value) => treatment = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Cases'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter number of cases' : null,
                    onSaved: (value) => cases = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Notes'),
                    onSaved: (value) => notes = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Day'),
                    validator: (value) => value!.isEmpty ? 'Enter day' : null,
                    onSaved: (value) => day = value!,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addDisease,
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: diseases.length,
                itemBuilder: (context, index) {
                  final disease = diseases[index];
                  return Card(
                    child: ListTile(
                      title: Text(disease['name']),
                      subtitle: Text(
                          'Symptoms: ${disease['symptoms']}\nTreatment: ${disease['treatment']}\nCases: ${disease['cases']}\nNotes: ${disease['notes']}\nDay: ${disease['day']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDisease(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
