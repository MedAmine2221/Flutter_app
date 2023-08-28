import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http; // Import the HTTP package
import 'package:stage_project/Screens/Acceuil/acceuil_screen.dart';
import 'package:stage_project/Screens/AcceuilUser/acceuil_user_screen.dart';
import 'dart:convert'; // Import the convert package
import 'package:stage_project/Screens/Login/components/background.dart';
import 'package:stage_project/Screens/Register/register_screen.dart';
import 'package:stage_project/components/Or_divider.dart';
import 'package:stage_project/components/already_have_an_account.dart';
import 'package:stage_project/components/rounded_button.dart';
import 'package:stage_project/components/rounded_cin_field.dart';
import 'package:stage_project/components/rounded_input_field.dart';
import 'package:stage_project/components/rounded_password_field.dart';
import 'package:get/get.dart';
import '../../../api/google_signIn_api.dart';

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
  String role = '';

  // Store the entered password
  String generateRandomString(int length) {
    final Random _random = Random();
    const String chars = "abcdefghijklmnopqrstuvwxyz0123456789"; // Caractères possibles
    String result = "";

    for (int i = 0; i < length; i++) {
      int randomIndex = _random.nextInt(chars.length);
      result += chars[randomIndex];
    }

    return result;
  }

  Future<void> SignIn() async {
    final user = await GoogleSignInApi.login();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign In Failed')),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please fill in your identity card number'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedCinField(
                    hintText: "Your CIN",
                    onChanged: (value) {
                      setState(() {
                        cin = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final user = await GoogleSignInApi.login();
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign In Failed')),
                    );
                  } else {
                    final response3 = await http.post(
                      Uri.parse('https://9e9b-196-229-191-69.ngrok.io/get_employee_id'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'cin': cin, // Replace with the actual CIN
                        'email': user.email, // Replace with the actual email
                      }),
                    );
                    final jsonResponse = json.decode(response3.body);
                    print('Response JSON: $jsonResponse');
                    if(jsonResponse['id']==null) {
                      password = generateRandomString(8);
                      final url = 'https://9e9b-196-229-191-69.ngrok.io/ajouter_employee';
                      final response = await http.post(
                        Uri.parse(url),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'email': user.email,
                          'mot_de_passe': password,
                          'cin': cin,
                          'nom': user.displayName,
                          'prenom': '',
                          'role': 'user',
                          'image': user.photoUrl
                        }),
                      );
                      final response2 = await http.post(
                        Uri.parse(
                            'https://9e9b-196-229-191-69.ngrok.io/get_employee_id'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(<String, dynamic>{
                          'cin': cin, // Replace with the actual CIN
                          'email': user.email, // Replace with the actual email
                        }),
                      );
                      final jsonResponse = json.decode(response2.body);
                      print('Response JSON: $jsonResponse');
                      final employeeId = jsonResponse['id']; // Utilisez 'id' au lieu de 'employee_id'
                      Get.to(UserScreen(), arguments: {
                        'email': user.email,
                        'nom': user.displayName,
                        'prenom': '',
                        'cin': cin,
                        'image': user.photoUrl,
                        'role': 'user',
                        'id': employeeId,
                      });
                      print('Employee ID: $employeeId');
                    }else{
                      Get.to(UserScreen(), arguments: {
                        'email': user.email,
                        'nom': user.displayName,
                        'prenom': '',
                        'cin': cin,
                        'image': user.photoUrl,
                        'role': 'user',
                        'id': jsonResponse['id'],
                      });
                    }
                  }
                },
                child: Text('Register'),
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
              Text('connection failed',style: TextStyle(fontWeight: FontWeight.bold),),
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
  void _showAlertFailedAcess(BuildContext context) {
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
              Text('NO ACCESS',style: TextStyle(fontWeight: FontWeight.bold),),
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

  Future<void> login() async {

    final url ='https://9e9b-196-229-191-69.ngrok.io/login';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'mot_de_passe': password,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      String role = jsonResponse['role'];
      if (role == 'user') {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserScreen()),
        );*/
        /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserScreen(email: jsonResponse['email'])),
        );*/
        Get.to(UserScreen(), arguments: {'email': jsonResponse['email'],'nom': jsonResponse['nom'],'prenom': jsonResponse['prenom'],'cin': jsonResponse['cin'],'image': jsonResponse['image'],'role': jsonResponse['role'],'id': jsonResponse['id']});

        print(jsonResponse['email']);
      } else if (role == 'admin') {
        Get.to(AcceuilScreen(), arguments: {'email': jsonResponse['email'],'nom': jsonResponse['nom'],'prenom': jsonResponse['prenom'],'cin': jsonResponse['cin'],'image': jsonResponse['image'],'role': jsonResponse['role'],'id': jsonResponse['id']});
      } else {
        _showAlertFailedAcess(context);
      }
    } else {
      _showAlertFailed(context);
    }
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
                borderRadius: BorderRadius.circular(50), // Ajustez le rayon du coin arrondi selon vos préférences
                child: Image.asset(
                  "assets/images/log.png",
                  height: size.height * 0.4,
                  fit: BoxFit.cover, // Assurez-vous que l'image s'adapte correctement au coin arrondi
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.03,
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
              RoundedButton(
                text: "SIGNIN",
                press: () {
                  login(); // Call the registration function
                },
              ),
              SizedBox(
                height: size.height * 0.005,
              ),
              AlreadyHaveAnAccount(
                login: true,
                press: () => Get.to(RegisterScreen()),
              ),
              OrDivider(),
              Container(
                width: 300,
                height: 50,
                child: TextButton(
                  onPressed: () async {SignIn();},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey, // Couleur de fond grise
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/google-plus.svg',
                        width: 30, // Ajustez la largeur selon vos besoins
                        height: 30, // Ajustez la hauteur selon vos besoins
                      ),
                      SizedBox(width: 8), // Ajustez l'espacement selon vos besoins
                      Text(
                        "Connect with Google",
                        style: TextStyle(
                          color: Colors.white, // Couleur du texte en blanc
                          fontWeight: FontWeight.bold, // Texte en gras
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
