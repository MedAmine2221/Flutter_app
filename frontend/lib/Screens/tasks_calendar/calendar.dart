import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stage_project/Screens/tasks_calendar/components/body.dart';

class TasksCalendar extends StatelessWidget{
  String cin = Get.arguments['cin'];
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Body(cin: cin),
    );
  }
}
