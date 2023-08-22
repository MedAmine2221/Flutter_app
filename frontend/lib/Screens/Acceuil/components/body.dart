import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:stage_project/Screens/Acceuil/components/background.dart';
import 'package:get/get.dart';
import 'package:stage_project/Screens/EmployeeEdit/employee_edit.dart';
import 'package:stage_project/Screens/Forum/forum.dart';
import 'package:stage_project/Screens/Inquiries/inquiries.dart';
import 'package:stage_project/Screens/Login/login_screen.dart';
import 'package:stage_project/Screens/Settings/settings.dart';
import 'package:stage_project/Screens/chart/Chart.dart';
import 'package:stage_project/Screens/notifquestion/notif_quest.dart';
import 'package:stage_project/components/edit_button.dart';
import 'package:stage_project/components/menu_profil.dart';
import 'dart:io';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Importez le package de notation
import 'package:http/http.dart' as http;

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

Future<void> _refreshPage() async {
  await Future.delayed(Duration(seconds: 2));
}
class _BodyState extends State<Body> {

  TextEditingController prenomController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  double userRating = 0; // Ajout de la variable pour la notation
  String SelectedImagePath = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String email = widget.email;
    String cin = widget.cin;
    String nom = widget.nom;
    String prenom = widget.prenom;
    String image = widget.image;
    String role = widget.role;
    int id = widget.id;
    bool isDarkMode = false;

    void showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
    selectImageFromGallery() async {
      XFile? file = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 10);
      if (file != null){
        return file.path;
      }else{
        return '';
      }
    }
    selectImageFromCamera() async {
      XFile? file = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 10);
      if (file != null){
        return file.path;
      }else{
        return '';
      }
    }

    Future selectImage(){
      return showDialog(
          context: context,
          builder: (BuildContext context){
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        'Select Image From !',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                SelectedImagePath = await selectImageFromGallery();
                                print('Image_path:-');
                                print(SelectedImagePath);
                                if (SelectedImagePath != ''){
                                  Navigator.pop(context);
                                  setState(() {

                                  });
                                }else{
                                  showSnackBar("No Image Selected !");
                                }
                              },
                              child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/gallery.png',
                                        height: 60,
                                        width: 60,
                                      ),
                                      Text("Gallery"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                SelectedImagePath = await selectImageFromCamera();
                                print("Image_path:-");
                                print(SelectedImagePath);
                                if (SelectedImagePath != ''){
                                  Navigator.pop(context);
                                  setState(() {

                                  });
                                }else{
                                  showSnackBar("No Image Captured !");
                                }
                              },
                              child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/camera.png',
                                        height: 60,
                                        width: 60,
                                      ),
                                      Text("camera"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
      );
    }

    _updateEmployee(BuildContext context) async {
      final url = 'https://771c-102-159-212-28.ngrok.io/editer_employee/${cin}';

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'new_nom': nomController.text,
          'new_prenom': prenomController.text,
          'new_email': emailController.text,
          'new_role': role,
          'new_image': SelectedImagePath,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Ferme la boîte de dialogue de modification
      } else {
        // Gérer l'erreur de mise à jour
        print('Erreur lors de la mise à jour de l\'employé.');
      }
    }
    void _editEmployeeDialog(BuildContext context) {
      /*TextEditingController prenomController = TextEditingController(text: prenom);
      TextEditingController nomController = TextEditingController(text: nom);
      TextEditingController emailController = TextEditingController(text: email);
      TextEditingController imageController = TextEditingController(text: image);*/
      prenomController.text = prenom;
      nomController.text = nom;
      emailController.text = email;
      imageController.text = image;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Profile Information'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: prenomController,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      hintText: "First Name",
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: nomController,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      hintText: "Last Name",
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: Colors.black,
                      ),
                      hintText: "Email",
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      padding:
                      MaterialStateProperty.all(const EdgeInsets.all(20)),
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 14, color: Colors.white),),),
                    onPressed: () async {
                      selectImage();
                      setState(() {

                      });
                    }, child: const Text("Select picture"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Perform the update logic here using the values from the controllers
                  // You can access the updated values using cinController.text,
                  // prenomController.text, nomController.text, and emailController.text
                  _updateEmployee(context);
                },
                child: Text('Update'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }

    return Background(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(bottom: 300),
          padding: const EdgeInsets.all(10),
          child: Column(
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
              Text("${widget.nom} ${widget.prenom}",
                  style: Theme.of(context).textTheme.headlineSmall),
              Text("${widget.email}",
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: EditButton(
                    text: 'Edit Profile',
                    press: (){
                      _editEmployeeDialog(context);
                    }
                  //=> Get.to(() => EditProfile()),
                ),
              ),
              SizedBox(height: 30),
              Divider(),
              SizedBox(height: 10),
              UserScreenMenu(
                title: "Settings",
                icon: LineAwesomeIcons.cog,
                onPress: () => Get.to(Settings(),
                    arguments: {
                      'email': email,
                      'nom': nom,
                      'prenom': prenom,
                      'cin': cin,
                      'image': image
                    }),
                isDarkMode: isDarkMode,
              ),
              UserScreenMenu(
                title: "Employee Settings",
                icon: LineAwesomeIcons.edit,
                onPress: () => Get.to(EmployeeEdit(),
                    arguments: {
                      'email': email,
                      'nom': nom,
                      'prenom': prenom,
                      'cin': cin,
                      'image': image
                    }),
                isDarkMode: isDarkMode,
              ),
              UserScreenMenu(
                title: "Notification",
                icon: LineAwesomeIcons.bell,
                onPress: () => Get.to(NotifQuest()),
                isDarkMode: isDarkMode,
              ),
              UserScreenMenu(
                title: "Chart",
                icon: LineAwesomeIcons.area_chart,
                onPress: () => Get.to(Chart()),
                isDarkMode: isDarkMode,
              ),
              Divider(),
              SizedBox(height: 10),
              UserScreenMenu(
                title: "Forum",
                icon: LineAwesomeIcons.comments,
                onPress: () => Get.to(() => Forum(),arguments: {
                  'id': id
                }),
                isDarkMode: isDarkMode,
              ),
              UserScreenMenu(
                title: "Logout",
                icon: LineAwesomeIcons.alternate_sign_out,
                textColor: Colors.red,
                endIcon: false,
                onPress: () => Get.to(() => LoginScreen()),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}