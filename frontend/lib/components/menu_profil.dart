import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'dart:io'; // Importez dart:io pour File
class UserScreenMenu extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;
  final bool isDarkMode;

  UserScreenMenu({
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var iconColor = isDarkMode ? Colors.amber : Colors.indigo;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.tealAccent.withOpacity(0.1)
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: Theme.of(context).textTheme.headline6?.apply(color: textColor)),
      trailing: endIcon
          ? Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withOpacity(0.1)
        ),
        child: Icon(LineAwesomeIcons.angle_right, size: 18.0, color: iconColor),
      )
          : null,
    );
  }

}