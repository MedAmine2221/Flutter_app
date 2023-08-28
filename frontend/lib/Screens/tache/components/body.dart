import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stage_project/Screens/Acceuil/acceuil_screen.dart';
import 'dart:convert';
import 'package:stage_project/Screens/projectmanager/components/background.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:stage_project/Screens/projectmanager/project_management.dart';

import 'package:stage_project/Screens/tache/project_tasks.dart';
import 'package:stage_project/components/project_text_field.dart';
import 'package:stage_project/components/rounded_button.dart';
import 'package:stage_project/constants.dart';
class Body extends StatefulWidget {
  final int id;
  final List<int> selectedEmployees;
  final String email;
  final String nom;
  final String prenom;
  final String cin;
  final String image;
  final String role;
  final int idconn;

  Body({
    required this.id,
    required this.selectedEmployees,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.cin,
    required this.image,
    required this.role,
    required this.idconn,
  });
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  DateTime dateDebut = DateTime.now();
  DateTime dateFin = DateTime.now();
  TextEditingController sujetController = TextEditingController();
  List<Employee> employees = [];
  int currentEmployeeIndex = 0;

  Future<void> _refreshPage() async {
    // Delay for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Perform any refresh-related tasks here
    // For example, you might want to fetch updated data or update the UI
    setState(() {
      // Update your state here
    });

    // Call the refresh function again to repeat the process
    _refreshPage();
  }


  Future<void> _selectDateDebut(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateDebut,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        dateDebut = picked;
      });
    }
  }

  Future<void> _selectDateFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        dateFin = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    _refreshPage();

  }
  void _showAlertFailed(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/wrong.png', // Remplacez par le chemin de votre image
                width: 100, // Ajustez la largeur de l'image selon vos besoins
                height: 100, // Ajustez la hauteur de l'image selon vos besoins
              ),
              Text('Task registration failed',style: TextStyle(fontWeight: FontWeight.bold),),

            ],
          ),
          actions: [
            RoundedButton(
              text:'Close',
              press: () {
                Navigator.of(context).pop(); // Ferme l'alerte
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse('https://9e9b-196-229-191-69.ngrok.io/liste_employees'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        List<Employee> allEmployees = responseData.map((employee) => Employee.fromJson(employee)).toList();

        // Filter the employees based on selectedEmployees list
        employees = allEmployees.where((employee) => widget.selectedEmployees.contains(employee.id)).toList();

        // If no employees were found in the selectedEmployees list, show an error
        if (employees.isEmpty) {
          print('No employees found in the selectedEmployees list');
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }
  Future<void> ajouterProjet() async {
    String apiUrl = 'https://9e9b-196-229-191-69.ngrok.io/ajouter_tache';

    Map<String, dynamic> data = {
      'projet_id': widget.id,
      'employee_id': employees[currentEmployeeIndex].id,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'description': sujetController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        if (currentEmployeeIndex < widget.selectedEmployees.length - 1) {
          setState(() {
            currentEmployeeIndex++;
            _resetForm();
          });
        } else {
          _showSuccessAlert(context);
        }
      } else {
        _showAlertFailed(context);
      }
    } catch (e) {
      print('Error adding project: $e');
    }
  }

  void _resetForm() {
    setState(() {
      dateDebut = DateTime.now();
      dateFin = DateTime.now();
      sujetController.clear();
    });
  }
  void _showSuccessAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 10),
              Text(
                'All tasks have been successfully registered!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.to(AcceuilScreen(),
                    arguments: {
                      'email': widget.email,
                      'nom': widget.nom,
                      'prenom': widget.prenom,
                      'cin': widget.cin,
                      'image': widget.image,
                      'role': widget.role,
                      'id': widget.idconn
                    }
                );
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //Employee selectedEmployee = employees.firstWhere((employee) => employee.isSelected, orElse: () => employees[0]);
    if (employees.isEmpty) {
      print(employees);
      return Center(
        child: Text('No employees found in the selectedEmployees list'),
      );
    }

    // Make sure that currentEmployeeIndex is within bounds
    if (currentEmployeeIndex >= employees.length) {
      currentEmployeeIndex = 0; // Reset to 0 if out of bounds
    }

    Employee selectedEmployee = employees[currentEmployeeIndex];
    return Background(
      //child: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ClipOval(
                child: employees[currentEmployeeIndex].image.startsWith("http")
                    ? Image.network(employees[currentEmployeeIndex].image, fit: BoxFit.cover)
                    : Image.file(File(employees[currentEmployeeIndex].image), fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text("${selectedEmployee.firstname} ${selectedEmployee.lastname}",
              style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _selectDateDebut(context),
                style: ElevatedButton.styleFrom(
                  primary: kPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
                icon: Icon(Icons.calendar_month), // Icône de calendrier
                label: Text(
                  '${DateFormat('dd/MM/yyyy').format(dateDebut)}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _selectDateFin(context),
                style: ElevatedButton.styleFrom(
                  primary: kPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
                icon: Icon(Icons.calendar_month), // Icône de calendrier
                label: Text(
                  '${DateFormat('dd/MM/yyyy').format(dateFin)}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.03),
          ProjectRoundedField(
            hintText: "Enter ${employees[currentEmployeeIndex].firstname}'s Tasks description",
            controller: sujetController,
            onChanged: (value) {
              // Gérez le changement de valeur du champ texte ici
            },
          ),

          SizedBox(height: 16),
          RoundedButton(
            text: 'Add Tasks',
            press: () {
              ajouterProjet();
            },
          ),
        ],
      ),
    ),
        ),
    );
  }
}
class Employee {
  final int id;
  final String lastname;
  final String firstname;
  final String image;
  bool isSelected;

  Employee({
    required this.id,
    required this.lastname,
    required this.firstname,
    required this.image,
    this.isSelected = false,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      lastname: json['lastname'],
      firstname: json['firstname'],
      image: json['image'],
    );
  }
}