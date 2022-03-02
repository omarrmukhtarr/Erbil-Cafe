
import 'package:erbilcafe/src/Navbar/BottomNavigationHelper.dart';
import 'package:erbilcafe/src/OnboardScreen/onboarding_screen.dart';
import 'package:erbilcafe/src/Registration/complete_profile/complete_profile_screen.dart';
import 'package:erbilcafe/src/Registration/forgot_password/forgot_password_screen.dart';
import 'package:erbilcafe/src/Registration/login_success/login_success_screen.dart';
import 'package:erbilcafe/src/Registration/otp/otp_screen.dart';
import 'package:erbilcafe/src/Registration/sign_in/sign_in_screen.dart';
import 'package:erbilcafe/src/Registration/sign_up/sign_up_screen.dart';
import 'package:erbilcafe/src/ShopScreen/Shop_Screen.dart';
import 'package:erbilcafe/src/profile/profile_screen.dart';
import 'package:flutter/material.dart';




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
          '/ShopScreen': (context) => ShopScreen(),
          '/ForgotPasswordScreen': (context) => ForgotPasswordScreen(),
          '/LoginSuccessScreen': (context) => LoginSuccessScreen(),
          '/ProfileScreen': (context) => ProfileScreen(),
          '/CompleteProfileScreen': (context) => CompleteProfileScreen(),
          
          
          
        });
  }
}
