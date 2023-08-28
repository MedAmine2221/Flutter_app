import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class CustomDatePicker extends StatelessWidget {
  final String labelText;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final Color backgroundColor; // Add this line

  const CustomDatePicker({
    required this.labelText,
    required this.selectedDate,
    required this.onDateChanged,
    required this.backgroundColor, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Adjust the width as needed
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor, // Use the provided background color
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                onDateChanged(pickedDate);
              }
            },
            child: Row(
              children: [
                Icon(LineAwesomeIcons.calendar, color: Colors.blue),
                SizedBox(width: 2),
                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}