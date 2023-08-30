import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stage_project/Screens/projectmanager/components/background.dart';
import 'dart:io';
import 'package:get/get.dart';

import 'package:stage_project/Screens/tache/project_tasks.dart';
import 'package:stage_project/components/custom-date_field.dart';
import 'package:stage_project/components/project_text_field.dart';
import 'package:stage_project/components/rounded_button.dart';
import 'package:stage_project/constants.dart';
import 'package:stage_project/constants.dart';
class Body extends StatefulWidget {
  final String email;
  final String nom;
  final String prenom;
  final String cin;
  final String image;
  final String role;
  final int id;

  Body({
    required this.email,
    required this.nom,
    required this.prenom,
    required this.cin,
    required this.image,
    required this.role,
    required this.id,
  });
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  DateTime dateDebut = DateTime.now();
  DateTime dateFin = DateTime.now();
  TextEditingController sujetController = TextEditingController();
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }
  void _showAlertFieldsRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 50,
              ),
              SizedBox(height: 10),
              Text('Please fill all the required fields', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            RoundedButton(
              text: 'Close',
              press: () {
                Navigator.of(context).pop(); // Ferme l'alerte
              },
            ),
          ],
        );
      },
    );
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
              SizedBox(height: 10),
              Text('project registration failed',style: TextStyle(fontWeight: FontWeight.bold),),
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
      final response = await http.get(Uri.parse('https://6d08-160-156-230-7.ngrok.io/liste_employees'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          employees = responseData.map((employee) => Employee.fromJson(employee)).toList();
        });
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }
  Future<void> ajouterProjet() async {
    String apiUrl = 'https://6d08-160-156-230-7.ngrok.io/ajouter_projet';
    List<int> selectedEmployeeIds = employees.where((employee) => employee.isSelected).map((e) => e.id).toList();

    Map<String, dynamic> data = {
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'sujet': sujetController.text,
      'employees': selectedEmployeeIds,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        int? projectId = responseData['id'] as int?;
        if (projectId != null) {
          print("PROJECT ID $projectId");
          print('$selectedEmployeeIds');
          Get.to(Tasks(),
              arguments:
              {
                'id': projectId,
                'selectedEmployees': selectedEmployeeIds,
                'email': widget.email,
                'nom': widget.nom,
                'prenom': widget.prenom,
                'cin': widget.cin,
                'image': widget.image,
                'role': widget.role,
                'idconn': widget.id

              });
        } else {
          // Handle the case where project_id is missing or null
          _showAlertFailed(context);
        }
      } else {
        _showAlertFailed(context);
      }
    } catch (e) {
      print('Error adding project: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.file(
                  File(widget.image),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "${widget.nom} ${widget.prenom}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              "${widget.email}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Add New Project',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomDatePicker(
                  labelText: 'Start',
                  selectedDate: dateDebut,
                  onDateChanged: (newDate) {
                    setState(() {
                      dateDebut = newDate;
                    });
                  },
                  backgroundColor: kPrimaryLightColor,
                ),
                CustomDatePicker(
                  labelText: 'End',
                  selectedDate: dateFin,
                  onDateChanged: (newDate) {
                    setState(() {
                      dateFin = newDate;
                    });
                  },
                  backgroundColor: kPrimaryLightColor,
                ),
              ],
            ),
            Container(
              height: 300, // Hauteur fixe pour la liste des employés
              child: ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipOval(
                        child: employee.image.startsWith("http")
                            ? Image.network(employee.image, fit: BoxFit.cover)
                            : Image.file(
                          File(employee.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text('${employee.firstname} ${employee.lastname}'),
                    trailing: Checkbox(
                      value: employee.isSelected,
                      onChanged: (value) {
                        setState(() {
                          employee.isSelected = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            ProjectRoundedField(
              hintText: 'Enter The project description',
              controller: sujetController,
              onChanged: (value) {
                // Gérez le changement de valeur du champ texte ici
              },
            ),
            RoundedButton(
              text: 'Add Project',
              press: () {
                if (dateDebut == null || dateFin == null || sujetController.text.isEmpty || employees.where((employee) => employee.isSelected).isEmpty) {
                  _showAlertFieldsRequired(context);
                } else {
                  ajouterProjet();
                }
              },
            ),
          ],
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