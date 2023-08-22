import 'package:flutter/material.dart';
import 'package:stage_project/Screens/Login/login_screen.dart';
import 'package:stage_project/Screens/Register/register_screen.dart';
import 'package:stage_project/Screens/Welcome/components/background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stage_project/constants.dart';
import 'package:stage_project/components/rounded_button.dart';

class Body extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "WELCOM TO EDU",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03,),
            SvgPicture.asset("assets/icons/chat.svg",height: size.height * 0.45,),
            SizedBox(height: size.height * 0.05,),
            RoundedButton(
              text: "LOGIN",
              press: () {Navigator.push(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);},
            ),
            RoundedButton(
                text: "REGISTER",
                color: kPrimaryLightColor,
                textColor: Colors.black,
                press: () {Navigator.push(context, MaterialPageRoute(builder: (context){return RegisterScreen();},),);}
            ),
          ],
        ),
      ),);
  }
}
