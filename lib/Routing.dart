import 'package:erbilcafe/Registration/login_success/components/body.dart';
import 'package:erbilcafe/Registration/otp/otp_screen.dart';
import 'package:erbilcafe/Registration/sign_in/sign_in_screen.dart';
import 'package:erbilcafe/Registration/sign_up/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:erbilcafe/screens/onboarding_screen.dart';
import 'package:erbilcafe/screens/BottomNavigationHelper.dart';
class Routing extends StatelessWidget {
  const Routing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
   debugShowCheckedModeBanner: false,
    initialRoute: '/',
     routes: {
      '/': (context) => OnboardingScreen(),
      '/Home': (context) => BottomNavigationHelper(),
      '/SignInScreen': (context) => SignInScreen(),
      '/SignUpScreen': (context) => SignUpScreen(),
      '/OtpScreen': (context) => OtpScreen(),
    });
  }
}
