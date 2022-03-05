import 'package:erbilcafe/size_config.dart';
import 'package:erbilcafe/src/profile/components/aboutUs.dart';
import 'package:flutter/material.dart';

import 'header_widget.dart';
import 'profile_menu.dart';
import 'profile_pic.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 100,
            child: HeaderWidget(100),
          ),
          SizedBox(
            height: 40,
          ),
          ProfilePic(),
          SizedBox(height: 20),
          Stack(
            children: [
              Column(
                children: [
                  Text(
                    "Omer Mukhtar Saeed",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text("OmerMukhtar@gmail.com"),
                ],
              )
            ],
          ),
          SizedBox(
            child: Divider(
              height: 10,
              endIndent: 20,
              indent: 20,
              thickness: 3,
              color: Colors.white54,
            ),
            height: 50,
          ),
          ProfileMenu(
            text: "My Account",
            icon: "assets/icons/User Icon.svg",
            press: () {
              Navigator.pushNamed(context, "/Aboutus");
            },
          ),
          ProfileMenu(
            text: "Sign up",
            icon: "assets/icons/Log In.svg",
            press: () {
              Navigator.pushNamed(context, '/SignUpScreen');
            },
          ),
          ProfileMenu(
            text: "Log In",
            icon: "assets/icons/Log In.svg",
            press: () {
              Navigator.pushNamed(context, '/SignInScreen');
            },
          ),
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons/Log out.svg",
            press: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ProfileMenu(
            text: "Settings",
            icon: "assets/icons/Settings.svg",
            press: () {
              Navigator.pushNamed(context, '/SignInScreen');
            },
          ),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/icons/Bell.svg",
            press: () {
              Navigator.pushNamed(context, '/OtpScreen');
            },
          ),
          ProfileMenu(
            text: "About Us",
            icon: "assets/icons/Question mark.svg",
            press: () {},
          ),
        ],
      ),
    );
  }
}
