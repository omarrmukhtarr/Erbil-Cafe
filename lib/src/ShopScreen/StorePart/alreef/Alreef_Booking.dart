import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AlreefBooking extends StatelessWidget {
  const AlreefBooking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#E6CCB2'),
      appBar: AppBar(
        title: Text("Booking Service",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            "Sorry, Service Not Availabe For Now (:",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
