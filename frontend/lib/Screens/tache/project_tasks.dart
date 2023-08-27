import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stage_project/Screens/tache/components/body.dart';

class Tasks extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    int id = Get.arguments['id'];
    List<int> selectedEmployees = Get.arguments['selectedEmployees'] ;
    String email = Get.arguments['email'];
    String nom = Get.arguments['nom'];
    String prenom = Get.arguments['prenom'];
    String cin = Get.arguments['cin'];
    String image = Get.arguments['image'];
    String role = Get.arguments['role'];
    int idconn = Get.arguments['idconn'];

    return Scaffold(
      body: Body(id:id, selectedEmployees: selectedEmployees, email: email, nom: nom, prenom: prenom, cin: cin, image: image, role: role, idconn: idconn),
    );
  }
}
