import 'package:erbilcafe/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don’t have an account? ",
          style: TextStyle(fontSize: getProportionateScreenWidth(15)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/SignUpScreen'),
          child: Text(
            "Sign Up",
            style: TextStyle(
                fontSize: getProportionateScreenWidth(18),
                color: HexColor('#d17842'),
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// HexColor('#d17842')