import 'package:flutter/material.dart';
import 'package:stage_project/constants.dart';

class EditButton extends StatelessWidget {
  final String text;
  final VoidCallback press; // Utilisation de VoidCallback
  final Color color, textColor;
  const EditButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = Colors.amber,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width *  0.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            backgroundColor: color,
          ),
          onPressed: press, // Utilisation directe de press
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}