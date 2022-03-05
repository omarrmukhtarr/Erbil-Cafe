// ignore_for_file: deprecated_member_use

import 'package:erbilcafe/src/OnboardScreen/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 130),
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      height: 10.0,
      width: isActive ? 24.0 : 12.0,
      decoration: BoxDecoration(
        color: isActive ? HexColor('#ddb892') : HexColor('#d17842'),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(color: HexColor('#141921')),
          child: Padding(
            padding: EdgeInsets.only(bottom: 40, top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _currentPage != _numPages - 3
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            alignment: Alignment.centerRight,
                            child: RaisedButton(
                              child: Text(
                                "Back",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              color: HexColor('#d17842'),
                              textColor: HexColor('#141921'),
                              padding: EdgeInsets.all(8.0),
                              splashColor: Colors.grey,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              alignment: Alignment.centerRight,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  "Skip",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                onPressed: () {
                                  _pageController.jumpToPage(_numPages);
                                },
                                color: HexColor('#d17842'),
                                textColor: HexColor('#141921'),
                                padding: EdgeInsets.all(8.0),
                                splashColor: Colors.grey,
                              )),
                        ],
                      )
                    : Text(''),
                Container(
                  height: 700.0,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/img/img1.png',
                                ),
                                height: 500.0,
                                width: 500.0,
                              ),
                            ),
                            Text(
                              'Erbil Cafe',
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'ئەپلیکەیشنی ئەربیل کافێ\nناساندنێکی گشتگیری کافێیەکانی هەولێرە',
                              style: kSubtitleStyle3,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/img/imgg.png',
                                ),
                                height: 400.0,
                                width: 400.0,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'What is the main goal of creating that app?',
                              style: kTitleStyle2,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'the goal, is to make it easier for people to choose their favorite place before they leave home, and to give a clear view of the Erbil cafeterias.',
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/img/img2.png',
                                ),
                                height: 400.0,
                                width: 400.0,
                              ),
                            ),
                            // SizedBox(height: 30.0),
                            Text(
                              'The benefits & services are available',
                              style: kTitleStyle3,
                            ),
                            SizedBox(height: 40.0),
                            Text(
                              ' 1- Booking Service \n 2- Location Thier Cafe \n 3- Menu Thier Cafe \n 4- Design Thier Cafe',
                              style: kSubtitleStyle2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage != _numPages - 1
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            child: Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: HexColor('#d17842'),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                        color: HexColor('#141921'),
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 10.0),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: HexColor('#141921'),
                                    size: 20.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
              height: 80.0,
              width: Size.infinite.width,
              color: HexColor('#d17842'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/SignInScreen');
                    },
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 30.0,
                        ),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: HexColor('#141921'),
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  new FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Home');
                    },
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 20.0,
                        ),
                        child: Text(
                          'Get started',
                          style: TextStyle(
                            color: HexColor('#141921'),
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Text(''),
    );
  }
}
