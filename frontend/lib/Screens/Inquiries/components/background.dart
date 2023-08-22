import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:stage_project/Screens/Welcome/Welcome_screen.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/main_top.png",
              width: size.width*0.5,
            ),
          ),

          /*Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: GNav(
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  activeColor: Colors.white,
                  tabBackgroundColor: Colors.grey.shade800,
                  gap: 8,
                  onTabChange: (index){
                    print(index);
                    if (index == 3){
                      Navigator.push(context, MaterialPageRoute(builder: (context){return WelcomeScreen();},),);
                    }
                    },
                  padding: EdgeInsets.all(16),
                  tabs: const [
                    GButton(icon: Icons.home,text: "Home",),
                    GButton(icon: Icons.person,text: "Profile",),
                    GButton(icon: Icons.settings,text: "Settings",),
                    GButton(icon: Icons.logout_rounded,text: "Logout",),
                  ],
                ),
              ),
            ),
          ),*/
          child,
        ],
      ),
    );
  }
}