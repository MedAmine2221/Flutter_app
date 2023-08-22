import 'package:flutter/material.dart';
import 'package:stage_project/Screens/Forum/components/body.dart';
import 'package:get/get.dart'; // Importez le package Get

class Forum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //String email = Get.arguments['email'];
    //String nom = Get.arguments['nom'];
    //String prenom = Get.arguments['prenom'];
    //String image = Get.arguments['image'];
    int id = Get.arguments['id'];

    return Scaffold(
      body: Body(id: id),
    );
  }
}