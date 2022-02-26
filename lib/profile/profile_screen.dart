import 'package:erbilcafe/screens/BottomNavigationHelper.dart';
import 'package:flutter/material.dart';

import 'package:erbilcafe/components/enums.dart';
import 'package:hexcolor/hexcolor.dart';

import 'components/body.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: HexColor('#E6CCB2'),
      body: Body(),
    );
  }
}
