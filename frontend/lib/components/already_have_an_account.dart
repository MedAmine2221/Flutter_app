import 'package:flutter/material.dart';
import 'package:stage_project/constants.dart';

class AlreadyHaveAnAccount extends StatelessWidget {
  final bool login;
  final VoidCallback press; // Utilisation de VoidCallback au lieu de Function
  const AlreadyHaveAnAccount({
    Key? key, // Utilisation de Key? au lieu de super.key
    this.login = true,
    required this.press,
  }) : super(key: key); // Utilisation de super(key: key)

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? "Don't have an Account ? " : "Already Have An Account ? ",
          style: TextStyle(color: kPrimaryColor),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Sign Up " : "Sign In ",
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}