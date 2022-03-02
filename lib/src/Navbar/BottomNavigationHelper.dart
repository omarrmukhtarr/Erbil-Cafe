import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:erbilcafe/src/Location.dart/Location_Screen.dart';
import 'package:erbilcafe/src/ShopScreen/Shop_Screen.dart';
import 'package:erbilcafe/src/TrendScreen/Popular_Screen.dart';
import 'package:erbilcafe/src/profile/profile_screen.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';

class BottomNavigationHelper extends StatefulWidget {
  const BottomNavigationHelper({Key? key}) : super(key: key);

  @override
  BottomNavigationHelperState createState() => BottomNavigationHelperState();
}

class BottomNavigationHelperState extends State<BottomNavigationHelper> {
  int selectedIndex = 0;
  List<Widget> Screens = [
    PopularScreen(),
    ShopScreen(),
    LocationScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          color: Color(0xff141921),
          backgroundColor: HexColor('#E6CCB2'),
          items: <Widget>[
            Icon(
              Icons.coffee_sharp,
              size: 30,
              color: HexColor('#E6CCB2'),
            ),
            Icon(Icons.storefront_outlined,
                size: 30, color: HexColor('#E6CCB2')),
            Icon(Icons.location_pin, size: 30, color: HexColor('#E6CCB2')),
            Icon(Icons.person, size: 30, color: HexColor('#E6CCB2')),
          ],
          onTap: (index) {
            selectedIndex = index;
            setState(() {});
          },
        ),
        body: Screens.elementAt(selectedIndex));
  }
}
