import 'package:flutter/material.dart';
import 'package:stage_project/components/text_field_container.dart';
import 'package:stage_project/constants.dart';

class InquiriesRoundedField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const InquiriesRoundedField({
    super.key,
    required this.hintText,
    this.icon = Icons.question_answer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
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