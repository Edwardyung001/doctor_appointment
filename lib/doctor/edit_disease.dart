import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_serivce.dart';
import 'disease_view_screen.dart';

class EditDiseaseScreen extends StatefulWidget {
  final int diseaseId; // ID of the disease

  EditDiseaseScreen({required this.diseaseId});

  @override
  _EditDiseaseScreenState createState() => _EditDiseaseScreenState();
}

class _EditDiseaseScreenState extends State<EditDiseaseScreen> {
  late TextEditingController nameController;
  late TextEditingController symptomsController;
  late TextEditingController treatmentController;
  late TextEditingController casesController;
  late TextEditingController notesController;
  late TextEditingController dayController;

  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    symptomsController = TextEditingController();
    treatmentController = TextEditingController();
    casesController = TextEditingController();
    notesController = TextEditingController();
    dayController = TextEditingController();

    _fetchDiseaseDetails();
  }

  // Fetch disease details by ID
  Future<void> _fetchDiseaseDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await ApiService.post("getDiseaseById",
        {"id": widget.diseaseId},
        token: token
    );

    if (response != null && response["status"] == true) {
      setState(() {
        nameController.text = response["disease"]["disease_name"];
        symptomsController.text = response["disease"]["symptoms"];
        treatmentController.text = response["disease"]["treatment"];
        casesController.text = response["disease"]["causes"].toString();
        notesController.text = response["disease"]["overview"];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response?["message"] ?? "Failed to fetch disease details";
        _isLoading = false;
      });
    }
  }


  // Update disease details
  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
      _errorMessage = "";
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final input = {
      "id": widget.diseaseId, // Required ID
      "name": nameController.text,
      "symptoms": symptomsController.text,
      "treatment": treatmentController.text,
      "cases": casesController.text,
      "notes": notesController.text,
    };

    print(input);

    final response = await ApiService.post("updateDiseases", input, token: token);

    print(response);

    if (response != null && response["status"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DiseaseTableScreen()),
      );
    } else {
      setState(() {
        _errorMessage = response?["message"] ?? "Failed to update disease";
      });
    }

    setState(() {
      _isSaving = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Disease"), backgroundColor: Colors.blue),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Disease Name")),
            TextField(controller: symptomsController, decoration: InputDecoration(labelText: "Symptoms")),
            TextField(controller: treatmentController, decoration: InputDecoration(labelText: "Treatment")),
            TextField(controller: casesController, decoration: InputDecoration(labelText: "Cases"), keyboardType: TextInputType.number),
            TextField(controller: notesController, decoration: InputDecoration(labelText: "Notes")),
            if (_errorMessage.isNotEmpty) // Show error message if any
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving ? CircularProgressIndicator() : Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
