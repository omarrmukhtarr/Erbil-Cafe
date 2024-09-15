import 'package:flutter/material.dart';

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
                    foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Colors.white),
                    ),
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
