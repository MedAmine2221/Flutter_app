import 'package:flutter/material.dart';
import 'package:stage_project/Screens/EmployeeEdit/components/body.dart';
import 'package:get/get.dart'; // Importez le package Get

class EmployeeEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String email = Get.arguments['email'];
    String nom = Get.arguments['nom'];
    String prenom = Get.arguments['prenom'];
    String image = Get.arguments['image'];

    return Scaffold(
      body: Body(email: email, nom: nom, prenom: prenom, image: image),
    );
  }
}