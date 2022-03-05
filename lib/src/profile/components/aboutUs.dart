import 'package:erbilcafe/src/profile/components/profile_pic.dart';
import 'package:erbilcafe/src/profile/components/profile_pic2.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Aboutus extends StatelessWidget {
  const Aboutus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("About us",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomLeft,
        //         colors: <Color>[
        //           Colors.black,
        //         ]),
        //   ),
        // ),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.orange,
          ],
        )),
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(child: ProfilePic2()),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Omer Mukhtar Saeed",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                )
              ],
            ),
            SizedBox(
              height: 40,
            ),
            InkWell(
              onTap: () {
                const url = 'https://www.instagram.com/omerrmukhtarr/';
                launchURL(url);
              },
              child: Container(
                height: 50,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.instagram,
                      size: 40,
                      color: Colors.orange[600],
                    ),
                    Text(
                      "Instagram",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            InkWell(
              onTap: () {
                const url =
                    'https://www.linkedin.com/in/omer-mukhtar-950b951b7/';
                launchURL(url);
              },
              child: Container(
                height: 50,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FaIcon(FontAwesomeIcons.linkedin,
                        size: 40, color: Colors.orange[600]),
                    Text(
                      "Linkedin",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            InkWell(
              onTap: () {
                const url = 'https://github.com/omerrmukhtarr';
                launchURL(url);
              },
              child: Container(
                height: 50,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FaIcon(FontAwesomeIcons.github,
                        size: 40, color: Colors.orange[600]),
                    Text(
                      "Github",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            InkWell(
              onTap: () {
                const url =
                    'https://stackoverflow.com/users/17595096/omer-mukhtar';
                launchURL(url);
              },
              child: Container(
                height: 50,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: FaIcon(FontAwesomeIcons.stackOverflow,
                          size: 40, color: Colors.orange[600]),
                    ),
                    Text(
                      "StackOverflow",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600]),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceWebView: true,
        universalLinksOnly: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
