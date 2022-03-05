import 'package:erbilcafe/src/ShopScreen/StorePart/NazdarhairanCafe/Nazdar_Booking.dart';

import 'package:erbilcafe/src/ShopScreen/StorePart/NazdarhairanCafe/menu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../size_config.dart';

class NazdarHairan extends StatefulWidget {
  final String imagePath;
  const NazdarHairan(this.imagePath);

  @override
  _NazdarHairanState createState() => _NazdarHairanState();
}

class _NazdarHairanState extends State<NazdarHairan>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return NazdarHairanPage(
      controller: _controller!,
      imagePath: widget.imagePath,
    );
  }
}

class NazdarHairanPage extends StatelessWidget {
  final imagePath;
  NazdarHairanPage(
      {Key? key, @required AnimationController? controller, this.imagePath})
      : animation = NazdarHairanPageEnterAnimation(controller!),
        super(key: key);
  final NazdarHairanPageEnterAnimation animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation.controller,
      builder: (context, child) => _buildAnimation(context),
    );
  }

  Hero _buildAnimation(BuildContext context) {
    SizeConfig().init(context);
    return Hero(
      tag: imagePath,
      child: Scaffold(
          backgroundColor: Colors.black,
          // backgroundColor: Colors.transparent,
          // floatingActionButton: ButtonTheme(
          //   minWidth: MediaQuery.of(context).size.width - 60,
          //   height: 56,
          //   child: RaisedButton(
          //     onPressed: () => {},
          //     shape: RoundedRectangleBorder(
          //         borderRadius: new BorderRadius.circular(15.0)),
          //     color: AppColor.lightSecondary,
          //     child: PrimaryText(
          //       text: 'Select location',
          //       size: 20,
          //     ),
          //   ),
          // ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(top: 20, bottom: 30),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => {Navigator.pop(context)},
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      // height: MediaQuery.of(context).size.height - 350,
                      height: animation.barHeight.value,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                        top: 30,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            HexColor('#141921'),
                            HexColor('#141921'),
                          ],
                        ),
                      ),
                      child: ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Nazdar Heyran Cafe',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange[900],
                                    ),
                                  )),
                              SizedBox(height: 30),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                    "قاوەخانەی نازدار حەیران، ناوەندێکی کلتوری و فەرھەنگی و ھزرییە. لەم شوێنە پێکەوەبوون بۆ بە فیڕۆدانی کات نییە، بەڵکو بۆ ناسینی یەکتری و تاوتوێکردنی ھزر و بەرنامەکانی یەکترییە. تۆ ئەگەر لە بێ ئیشیشدا بێیتە ئەوێ، لانیکەم قەدر و بەھای خۆت دەبینیتەوە و کەسانێک دەناسی و دەبینیت کە لە شوێنی تر بۆت ناڕەخسێت!,تۆ لایق بەوەیت شوێنێکت ھەبێت تیایدا ھەنگاوەکانت بەوانی تر بگەیەنیت! ھەوڵ ئەدەین بیرۆکەکانت بۆ بکەینە کردار، گەرنەمان توانی، تۆ دەبیتە میوانێکی ڕێزلێگیراوی ئێمە",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white54,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  )),
                              SizedBox(height: 10),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(0.8),
                                  child: SizedBox(
                                    width: 56,
                                    height: getProportionateScreenHeight(56),
                                    child: IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.instagram,
                                        size: 45,
                                        color: Colors.orange[900],
                                      ),
                                      onPressed: () {
                                        const url =
                                            'https://www.instagram.com/nazdarheyran/';
                                        launchURL(url);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0.8),
                                    child: SizedBox(
                                      width: 150,
                                      height: getProportionateScreenHeight(56),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          primary: Colors.white,
                                          backgroundColor: HexColor('#ddb892'),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NazdarMenu(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          ' Menu',
                                          style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenWidth(
                                                      18),
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: SizedBox(
                                      width: 150,
                                      height: getProportionateScreenHeight(56),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          primary: Colors.white,
                                          backgroundColor: HexColor('#ddb892'),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NazdarHairanBooking(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Booking Now',
                                          style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenWidth(
                                                      16),
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Cafe  Design',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange[900],
                                      ),
                                    ),
                                  ),
                                  // PrimaryText(
                                  //     text: '18',
                                  //     size: 16,
                                  //     fontWeight: FontWeight.w700,
                                  //     color: Colors.white24),
                                ],
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: SizedBox(
                                  height: 500,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      hotNazdarHairanCard(
                                          'assets/shop/nazdar/n1.jpg',
                                          'AMERICA',
                                          '18 Tourist Place',
                                          context),
                                      hotNazdarHairanCard(
                                          'assets/shop/nazdar/n2.jpg',
                                          'JAPAN',
                                          '18 Tourist Place',
                                          context),
                                      hotNazdarHairanCard(
                                          'assets/shop/nazdar/n3.jpg',
                                          'NEWYORK',
                                          '18 Tourist Place',
                                          context),
                                      hotNazdarHairanCard(
                                          'assets/shop/nazdar/n4.jpg',
                                          'NEWYORK',
                                          '18 Tourist Place',
                                          context),
                                      hotNazdarHairanCard(
                                          'assets/shop/nazdar/n5.jpg',
                                          'NEWYORK',
                                          '18 Tourist Place',
                                          context),
                                      hotNazdarHairanCard(
                                          'assets/shop/nazdar/n6.jpg',
                                          'NEWYORK',
                                          '18 Tourist Place',
                                          context),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget hotNazdarHairanCard(String imagePath, String placeName,
      String touristPlaceCount, BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => NazdarHairan(imagePath)))
      },
      child: Stack(children: [
        Container(
          height: 450,
          width: 350,
          margin: EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ]),
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

class NazdarHairanPageEnterAnimation {
  NazdarHairanPageEnterAnimation(this.controller)
      : barHeight = Tween<double>(begin: 0, end: 600).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0, 0.5),
          ),
        );

  final AnimationController controller;
  final Animation<double> barHeight;
}
