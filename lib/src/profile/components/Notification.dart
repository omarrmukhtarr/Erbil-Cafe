import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    var switchState;
    return Scaffold(
      body: Center(
        child: Container(
          child: CupertinoSwitch(
            value: switchState,
            onChanged: (bool? value) {
              setState(() {
                switchState = value;
              });
              print(value);
            },
          ),
        ),
      ),
    );
  }
}
