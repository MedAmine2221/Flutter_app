import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stage_project/components/inquiries_field_text.dart';
import 'package:stage_project/components/rounded_button.dart';
import 'dart:io';
import 'package:stage_project/Screens/Forum/components/body.dart';

class Inquiries extends StatefulWidget {
  @override
  _InquiriesState createState() => _InquiriesState();
}

class _InquiriesState extends State<Inquiries> {
  String email = Get.arguments['email'];
  String nom = Get.arguments['nom'];
  String prenom = Get.arguments['prenom'];
  String image = Get.arguments['image'];
  int id = Get.arguments['id'];
  String questionText = ""; // Renamed from question_text

  void _showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/verif.png', // Remplacez par le chemin de votre image
                width: 100, // Ajustez la largeur de l'image selon vos besoins
                height: 100, // Ajustez la hauteur de l'image selon vos besoins
              ),
              SizedBox(height: 10),
              Text('message sent successfully',style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
          actions: [
            RoundedButton(
              text:'Close',
              press: () {
                Navigator.of(context).pop();
                fetchEmployeesMessages();// Ferme l'alerte
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
              Text('Message is not sent',style: TextStyle(fontWeight: FontWeight.bold),),
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
  Future<void> registerQuest() async {
    final url = 'https://771c-102-159-212-28.ngrok.io/envoyer_question';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'employee_id': id,
        'question_text': questionText,
      }),
    );

    if (response.statusCode == 201) {
      _showAlert(context);
    } else {
      _showAlertFailed(context);
    }
  }

  List<Map<String, dynamic>> employees = [];
  int _selectedQuestionIndex = -1;
  //String _commentController = '';
  Map<int, List<dynamic>> employeeResponses = {
  }; // Map pour stocker les réponses des employés par ID de question

  Future<void> fetchEmployeesMessages() async {
    final response = await http.get(
        Uri.parse(
            'https://771c-102-159-212-28.ngrok.io/afficher_employees_messages'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        employees = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to load data');
    }

    for (var employee in employees) {
      final questionId = employee['id'];
      final response = await http.get(Uri.parse(
          'https://771c-102-159-212-28.ngrok.io/afficher_reponses_employes/$questionId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        employeeResponses[questionId] = responseData;
      } else {
        print('Failed to load responses for question $questionId');
      }
    }
  }

  Future<void> _refreshPage() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    _refreshPage();
    fetchEmployeesMessages();
  }

  TextEditingController _commentController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.file(
                    File(image),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(nom + " " + prenom,
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(email, style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 20),
              InquiriesRoundedField(
                onChanged: (value) {
                  setState(() {
                    questionText = value;
                  });
                },
                hintText: 'Enter your text...',
              ),
              RoundedButton(
                text: "send",
                press: () {
                  registerQuest();
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                var employee = employees[index];
                List<dynamic> messages = List<dynamic>.from(
                    employee['messages'] ?? []);
                List<String> questionTexts = messages
                    .where((msg) => msg is String)
                    .cast<String>()
                    .toList();
                var employeeResponse = employeeResponses[employee['id']] ?? [];

                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.file(
                                File(employee['image']),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded( // Utiliser Expanded pour que le texte prenne l'espace disponible
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${employee['nom']} ${employee['prenom']}'),
                                SizedBox(height: 5),
                                ViewMoreText(
                                  text: '${questionTexts.join(', ')}',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.comment),
                                      onPressed: () {
                                        setState(() {
                                          _selectedQuestionIndex = index;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.thumb_up),
                                      onPressed: () {
                                        // Implémentez la logique pour aimer le message
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedQuestionIndex == index)
                      Column(
                        children: [
                          for (var response in employeeResponse)
                            ListTile(
                              title: Text(
                                  '${response['employee_nom']} ${response['employee_prenom']}   ${response['reponse_created_at']} : '),
                              subtitle: ViewMoreText(
                                text: '${response['reponse_text']}',
                                style: TextStyle(fontSize: 20),
                              ),
                              leading: CircleAvatar(
                                backgroundImage: FileImage(
                                    File(response['employee_image'])), // Assurez-vous que 'employee_image' est correct
                              ),

                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}