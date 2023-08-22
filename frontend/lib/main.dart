import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Importez le package Get
import 'package:stage_project/Screens/Welcome/Welcome_screen.dart';
import 'package:stage_project/constants.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Utilisez GetMaterialApp au lieu de MaterialApp
      debugShowCheckedModeBanner: false,
      title: 'EMPLOYEE MANAGEMENT',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home:  WelcomeScreen(),
    );
  }
}