import 'package:flutter/material.dart';
import 'package:erbilcafe/size_config.dart';
import 'package:hexcolor/hexcolor.dart';

import 'components/body.dart';

class OtpScreen extends StatelessWidget {
  static String routeName = "/otp";
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: HexColor('#E6CCB2'),
      appBar: AppBar(
        title: Text("OTP Verification",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Body(),
    );
  }
}
