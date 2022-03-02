import 'package:erbilcafe/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'components/body.dart';

class CompleteProfileScreen extends StatelessWidget {
  static String routeName = "/complete_profile";
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: HexColor('#E6CCB2'),
      appBar: AppBar(
        title: Text('Sign Up',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Body(),
    );
  }
}
