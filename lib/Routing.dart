

import 'package:erbilcafe/src/Navbar/BottomNavigationHelper.dart';
import 'package:erbilcafe/src/OnboardScreen/onboarding_screen.dart';

import 'package:erbilcafe/src/ShopScreen/Shop_Screen.dart';
import 'package:erbilcafe/src/ShopScreen/StorePart/BarberaCafe/Barbera_Cafe.dart';
import 'package:erbilcafe/src/ShopScreen/StorePart/BarberaCafe/menu.dart';
import 'package:erbilcafe/src/ShopScreen/StorePart/NazdarhairanCafe/NazdarhairanCafe.dart';
import 'package:erbilcafe/src/complete_profile/complete_profile_screen.dart';
import 'package:erbilcafe/src/forgot_password/forgot_password_screen.dart';
import 'package:erbilcafe/src/login_success/login_success_screen.dart';
import 'package:erbilcafe/src/otp/otp_screen.dart';
import 'package:erbilcafe/src/profile/components/Notification.dart';
import 'package:erbilcafe/src/profile/components/aboutUs.dart';
import 'package:erbilcafe/src/profile/profile_screen.dart';
import 'package:erbilcafe/src/sign_in/sign_in_screen.dart';
import 'package:erbilcafe/src/sign_up/sign_up_screen.dart';
import 'package:flutter/material.dart';

class Routing extends StatelessWidget {
  const Routing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: "RalewaySemi"),
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
          // '/BarberaCafe': (context) => BarberaCafe(),
          // '/Destination': (context) => Destination(),
          '/MenuBarberaCafe': (context) => MenuBarberaCafe(),
          '/Aboutus': (context) => Aboutus(),
          '/Notifications': (context) => Notifications(),
        });
  }
}
