import 'package:doctor/network/api_serivce.dart';
import 'package:flutter/material.dart';
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
   bool _isLoading=false;

  Future<void> addDisease() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final newDisease = {
      "name": diseaseName,
      "symptoms": symptoms,
      "treatment": treatment,
      "cases": cases,
      "notes": notes,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
print(token);
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post("diseases", newDisease, token: token);

      setState(() {
        _isLoading = false;
      });

      if (response != null && response["status"] == true) {
        setState(() {
          diseases.add(response['disease']);
        });
        _formKey.currentState!.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Disease added successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?["message"] ?? "Failed to add disease.")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
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
                    decoration: InputDecoration(labelText: 'Causes'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter number of cases' : null,
                    onSaved: (value) => cases = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'overview'),
                    onSaved: (value) => notes = value!,
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
                      title: Text(disease['disease_name']),
                      subtitle: Text(
                          'Symptoms: ${disease['symptoms']}\nTreatment: ${disease['treatment']}\nCases: ${disease['causes']}\nNotes: ${disease['overview']}'),
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
