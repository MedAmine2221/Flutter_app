import 'package:flutter/material.dart';
import 'package:stage_project/components/text_field_container.dart';
import 'package:stage_project/constants.dart';

class RoundedCinField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedCinField({
    super.key,
    required this.hintText,
    this.icon = Icons.assignment_ind,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),);
  }
}