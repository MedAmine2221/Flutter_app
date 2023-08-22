import 'package:flutter/material.dart';
import 'package:stage_project/Screens/Settings/components/body.dart';
import 'package:get/get.dart'; // Importez le package Get
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String email = Get.arguments['email'];
    String nom = Get.arguments['nom'];
    String cin = Get.arguments['cin'];
    String prenom = Get.arguments['prenom'];
    String image = Get.arguments['image'];

    return Scaffold(
      body: Body(email: email, nom: nom, prenom: prenom, cin: cin, image: image),
    );
  }
}