import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stage_project/Screens/projectmanager/components/body.dart';

class ProjectManager extends StatelessWidget{
  String email = Get.arguments['email'];
  String nom = Get.arguments['nom'];
  String prenom = Get.arguments['prenom'];
  String cin = Get.arguments['cin'];

  String image = Get.arguments['image'];
  String role = Get.arguments['role'];
  int id = Get.arguments['id'];

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Body(email: email, nom: nom, prenom: prenom, cin:cin, image: image, role: role, id: id),
    );
  }
}