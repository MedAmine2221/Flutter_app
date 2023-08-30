/*import 'package:flutter/material.dart';
import 'package:stage_project/components/text_field_container.dart';
import 'package:stage_project/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedInputField({
    super.key,
    required this.hintText,
    this.icon = Icons.mail,
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
}*/
import 'package:flutter/material.dart';
import 'package:stage_project/components/text_field_container.dart';
import 'package:stage_project/constants.dart';

class RoundedInputField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    this.icon = Icons.mail,
    required this.onChanged,
  }) : super(key: key);

  @override
  _RoundedInputFieldState createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {
  bool _isValidEmail = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: (value) {
          setState(() {
            _isValidEmail = _validateEmail(value);
          });
          widget.onChanged(value);
        },
        decoration: InputDecoration(
          icon: Icon(
            widget.icon,
            color: kPrimaryColor,
          ),
          hintText: widget.hintText,
          border: InputBorder.none,
          errorText: _isValidEmail ? null : 'Enter a valid email address',
        ),
      ),
    );
  }

  bool _validateEmail(String value) {
    // Cette fonction valide la forme de l'adresse e-mail
    // Vous pouvez utiliser une expression régulière ou d'autres méthodes pour la validation
    // Ici, j'utilise simplement une vérification de base pour la démonstration
    return value.isEmpty || value.contains('@') && value.contains('.');
  }
}

