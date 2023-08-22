import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Body extends StatefulWidget {
  final int id;

  Body({
    required this.id,
  });

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
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
    return Column(
      children: <Widget>[
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _commentController,
                              onChanged: (value) {
                                // On peut supprimer cette partie, car _commentController est déjà mis à jour automatiquement
                              },
                              decoration: InputDecoration(
                                hintText: 'Entrez votre réponse...',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              final response = await http.post(
                                Uri.parse(
                                    'https://771c-102-159-212-28.ngrok.io/enregistrer_reponse'),
                                body: jsonEncode({
                                  'employee_id': widget.id,
                                  'question_id': employee['id'],
                                  // Remplacez par l'ID de la question réelle
                                  'reponse_text': _commentController.text,
                                }),
                                headers: {'Content-Type': 'application/json'},
                              );

                              print('Code de statut de la réponse : ${response
                                  .statusCode}');
                              print('Corps de la réponse : ${response.body}');

                              if (response.statusCode == 201) {
                                final newResponse = {
                                  'employee_nom': employee['nom'],
                                  'employee_prenom': employee['prenom'],
                                  'reponse_text': _commentController.text,
                                  'employee_image': 'url_de_l_image',
                                  // Remplacez par l'URL de l'image de l'employé
                                  'reponse_created_at': DateTime.now()
                                      .toString(),
                                };

                                setState(() {
                                  if (!employeeResponses.containsKey(
                                      employee['id'])) {
                                    employeeResponses[employee['id']] =
                                    [newResponse];
                                  } else {
                                    employeeResponses[employee['id']]!.add(
                                        newResponse);
                                  }
                                  _selectedQuestionIndex = -1;
                                  _commentController
                                      .clear(); // Vider le champ après l'envoi
                                });
                              } else {
                                // Gérer l'erreur
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  else
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
    );
  }
}

class ViewMoreText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  ViewMoreText({required this.text, required this.style, this.maxLines = 2});

  @override
  _ViewMoreTextState createState() => _ViewMoreTextState();
}

class _ViewMoreTextState extends State<ViewMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: isExpanded ? null : widget.maxLines,
          overflow: TextOverflow.clip,
        ),
        if (widget.text.length > widget.maxLines * 40) // Adjust the threshold as needed
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? 'see less' : 'see more',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}