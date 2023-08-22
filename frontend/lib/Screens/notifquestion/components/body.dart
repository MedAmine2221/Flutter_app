import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<Map<String, dynamic>> messages = [];
  late Timer _timer;

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse('https://771c-102-159-212-28.ngrok.io/notification'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, dynamic>> sortedMessages = List<Map<String, dynamic>>.from(data);
        sortedMessages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        setState(() {
          messages = sortedMessages;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  void _refreshData() {
    fetchMessages();
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          for (Map<String, dynamic> message in messages)
            EmployeeMessageCard(
              name: "${message['nom']} ${message['prenom']}",
              timestamp: message['timestamp'],
              image: message['image'],
              isNew: message['new'] ?? false,
              isMostRecent: message == messages.first, // Nouvelle propriété

            ),
        ],
      ),
    );
  }
}
class EmployeeMessageCard extends StatelessWidget {
  final String name;
  final String timestamp;
  final String image;
  final bool isNew;
  final bool isMostRecent; // Nouvelle propriété

  EmployeeMessageCard({
    required this.name,
    required this.timestamp,
    required this.image,
    this.isNew = false,
    this.isMostRecent = false, // Initialisé à false par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isNew || isMostRecent) // Condition mise à jour ici
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMostRecent ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isMostRecent ? "new" : "",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              CircleAvatar(
                backgroundImage: FileImage(File(image)),
                radius: 25,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${name} send a question",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    timestamp,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Body(),
    ),
  ));
}