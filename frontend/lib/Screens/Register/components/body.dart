import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:stage_project/Screens/Login/login_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:stage_project/Screens/Register/components/background.dart';
import 'package:stage_project/components/Or_divider.dart';
import 'package:stage_project/components/already_have_an_account.dart';
import 'package:stage_project/components/rounded_button.dart';
import 'package:stage_project/components/rounded_cin_field.dart';
import 'package:stage_project/components/rounded_field.dart';
import 'package:stage_project/components/rounded_input_field.dart';
import 'package:stage_project/components/rounded_password_field.dart';
import 'package:stage_project/components/social_icon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String email = ''; // Store the entered email
  String password = '';
  String cin = '';
  String nom = '';
  String prenom = '';
  String role = 'user';
  String SelectedImagePath = '';
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
              Text('Registration successful',style: TextStyle(fontWeight: FontWeight.bold),),
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
              Text('Registration failed',style: TextStyle(fontWeight: FontWeight.bold),),
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

  Future<void> registerUser() async {
    final url = 'https://ddae-160-156-223-236.ngrok.io/ajouter_employee'; // Replace with your actual API endpoint

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'mot_de_passe': password,
        'cin':cin,
        'nom':nom,
        'prenom':prenom,
        'role':role,
        'image':SelectedImagePath
      }),
    );

    if (response.statusCode == 201) {
      // Registration successful
      //print('Registration successful');
      _showAlert(context);
      // You can navigate to another page or show a success message here
    } else {
      // Registration failed
      _showAlertFailed(context);
      // You can show an error message here
    }
    print(SelectedImagePath);
  }

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Ajustez le rayon du coin arrondi selon vos préférences
                child: Image.asset(
                  "assets/images/reg.jpg",
                  height: size.height * 0.4,
                  fit: BoxFit.cover, // Assurez-vous que l'image s'adapte correctement au coin arrondi
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Text(
                "SIGN UP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              RoundedCinField(
                hintText: "Your CIN",
                onChanged: (value) {
                  setState(() {
                    cin = value;
                  });
                },
              ),
              RoundedField(
                hintText: "Your First Name",
                onChanged: (value) {
                  setState(() {
                    prenom = value;
                  });
                },
              ),
              RoundedField(
                hintText: "Your Last Name",
                onChanged: (value) {
                  setState(() {
                    nom = value;
                  });
                },
              ),
              RoundedInputField(
                hintText: "Your Email",
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              RoundedPasswordField(
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                hintText: "Password",
              ),
              SelectedImagePath == ''
                  ? Image.asset('assets/images/image_placeholder.png',height: 200,width: 200,fit: BoxFit.cover,)
                  :Image.file(File(SelectedImagePath), height:200, width:200,fit:BoxFit.fill,),
              Text(
                'Select picture',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),
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
                }, child: const Text("Select"),
              ),
              RoundedButton(
                text: "SIGNUP",
                press: () {
                  registerUser(); // Call the registration function
                },
              ),
              SizedBox(
                height: size.height * 0.005,
              ),
              AlreadyHaveAnAccount(
                  login: false,
                  press: () => Get.to(LoginScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
