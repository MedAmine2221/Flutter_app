import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
class UserScreenGoogle extends StatelessWidget{
  final GoogleSignInAccount user;
  UserScreenGoogle({
    Key? key,
    required this.user,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      alignment: Alignment.center,
      color: Colors.blueGrey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "Profile"
          ),
          SizedBox(height:32),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(user.photoUrl!),
          ),
          SizedBox(height:8),
          Text(
            'Name ' + user.displayName!,
          ),
          SizedBox(height:8),
          Text(
            'Email ' + user.email!,
          ),
        ],
      ),
    ),
  );
}