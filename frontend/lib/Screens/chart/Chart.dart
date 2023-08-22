import 'package:flutter/material.dart';
import 'package:stage_project/Screens/chart/components/body.dart';

class Chart extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Body(),
    );
  }
}
