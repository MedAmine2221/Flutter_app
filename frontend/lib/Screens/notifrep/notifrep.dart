import 'package:flutter/material.dart';
import 'package:stage_project/Screens/notifrep/components/body.dart';

class NotifRep extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Body(),
    );
  }
}
