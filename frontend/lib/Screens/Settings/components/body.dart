import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:stage_project/Screens/AcceuilUser/components/background.dart';
import 'package:get/get.dart'; // Importez le package Get
import 'package:stage_project/Screens/Login/login_screen.dart';
import 'package:stage_project/components/edit_button.dart';
import 'package:stage_project/components/menu_profil.dart';
import 'dart:io';
import 'package:http/http.dart' as http; // Import the HTTP package

import 'package:stage_project/components/rounded_button.dart';
import 'package:stage_project/components/rounded_password_field.dart';

class Body extends StatefulWidget {
  //final String email; // Ajoutez cette propriété

  //Body({required this.email}); // Mettez à jour le constructeur
  final String email;
  final String nom;
  final String prenom;
  final String cin;
  final String image;

  Body({
    required this.email,
    required this.nom,
    required this.prenom,
    required this.cin,
    required this.image
  });

  @override
  _BodyState createState() => _BodyState();
}
Future<void> _refreshPage() async {
  // Mettez ici le code de chargement ou de mise à jour des données.
  // Par exemple, vous pourriez appeler une API pour obtenir de nouvelles données.
  await Future.delayed(Duration(seconds: 2)); // Simule un chargement de 2 secondes.
}

class _BodyState extends State<Body> {
  bool isDarkMode = false; // Initialisé à false pour le mode clair

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String old_password='';
    String new_password='';
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
                Text('Edit successful',style: TextStyle(fontWeight: FontWeight.bold),),
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
                Text('Edit Failed',style: TextStyle(fontWeight: FontWeight.bold),),
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
    void _showAlertWrongPass(BuildContext context) {
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
                Text('incorrect password',style: TextStyle(fontWeight: FontWeight.bold),),
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
    Future<void> updatepass() async {
      final url = 'https://9151-102-157-69-97.ngrok.io/changer_mot_de_passe'; // Replace with your actual API endpoint

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cin': '${widget.cin}',
          'mot_de_passe_actuel': old_password,
          'nouveau_mot_de_passe': new_password,
        }),
      );

      if (response.statusCode == 200) {
        _showAlert(context);
      } else if (response.statusCode == 401){
        _showAlertWrongPass(context);
      }else {
        _showAlertFailed(context);
      }
    }
    void editPassword() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Edit Password'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundedPasswordField(
                      onChanged: (value) {
                        setState(() {
                          old_password = value;
                        });
                      },
                      hintText: "Current Password",
                    ),
                    SizedBox(height: 10),
                    RoundedPasswordField(
                      onChanged: (value) {
                        setState(() {
                          new_password = value;
                        });
                      },
                      hintText: "New Password",
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    updatepass();
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            );
          }
      );
    }
    return Background(

      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(bottom: 300), // Ajustez cette marge pour déplacer le contenu vers le haut
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.file(
                    File('${widget.image}'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("${widget.nom} ${widget.prenom}",style: Theme.of(context).textTheme.headlineSmall,),
              Text("${widget.email}",style: Theme.of(context).textTheme.bodyLarge,),
              SizedBox(height: 20,),
              SizedBox(height: 30,),
              Divider(),
              SizedBox(height: 10,),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.tealAccent.withOpacity(0.1),
                  ),
                  child: Icon(LineAwesomeIcons.moon, color: Colors.indigo),
                ),
                title: Text(
                  'Dark Mode ?',
                  style: Theme.of(context).textTheme.headline6?.apply(color: Colors.black),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) async {
                    setState(() {
                      isDarkMode = value;
                    });

                    if (isDarkMode) {
                      Get.changeTheme(ThemeData.dark());
                      await _refreshPage(); // Appel de la fonction de rafraîchissement ici
                    } else {
                      Get.changeTheme(ThemeData.light());
                    }
                  },
                ),
              ),
              UserScreenMenu(title: "change password",icon: LineAwesomeIcons.lock,onPress: () =>{editPassword()},isDarkMode:isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
}