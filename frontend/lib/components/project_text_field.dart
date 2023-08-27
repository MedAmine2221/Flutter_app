import 'package:flutter/material.dart';
import 'package:stage_project/components/text_field_container.dart';
import 'package:stage_project/constants.dart';

class ProjectRoundedField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller; // Add this line
  final ValueChanged<String> onChanged;

  const ProjectRoundedField({
    required this.hintText,
    this.icon = Icons.question_answer,
    required this.controller, // Add this line
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        controller: controller, // Add this line
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}