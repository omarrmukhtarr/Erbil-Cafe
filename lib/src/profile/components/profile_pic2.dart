import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePic2 extends StatelessWidget {
  const ProfilePic2({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/ProfileImage.png"),
          ),
          Positioned(
            right: 1,
            bottom: 0,
            child: SizedBox(
              height: 34,
              width: 34,
              child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Colors.white),
                    ),
                    primary: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {},
                  child: Text(
                    "Dev",
                    style: TextStyle(fontSize: 9),
                  )
                  //  SvgPicture.asset(
                  //   "assets/icons/Camera Icon.svg",
                  //   color: Colors.white,
                  // ),
                  ),
            ),
          )
        ],
      ),
    );
  }
}
