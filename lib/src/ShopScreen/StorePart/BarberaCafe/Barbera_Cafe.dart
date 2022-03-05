import 'package:erbilcafe/src/ShopScreen/StorePart/BarberaCafe/Barbera_Booking.dart';
import 'package:erbilcafe/src/ShopScreen/StorePart/BarberaCafe/menu.dart';

import 'package:erbilcafe/src/ShopScreen/style.dart';
import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';

import '../../../../size_config.dart';

class BarberaCafe extends StatefulWidget {
  final String imagePath;
  const BarberaCafe(this.imagePath);

  @override
  _BarberaCafeState createState() => _BarberaCafeState();
}

class _BarberaCafeState extends State<BarberaCafe>
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
    return BarberaCafePage(
      controller: _controller!,
      imagePath: widget.imagePath,
    );
  }
}

class BarberaCafePage extends StatelessWidget {
  final imagePath;
  BarberaCafePage(
      {Key? key, @required AnimationController? controller, this.imagePath})
      : animation = BarberaCafePageEnterAnimation(controller!),
        super(key: key);
  final BarberaCafePageEnterAnimation animation;

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
                                    'Barbera Cafe',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange[900],
                                    ),
                                  )),
                              SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: PrimaryText(
                                    text:
                                        'A Family Company Since 1870.\nIt all starts with coffee from Italy’s oldest coffee roasting company.\nSouthern Italy 1870. The bracing air of early morning is enriched with intense fragrance in via Garibaldi where the little shop of colonial products radiate light and aromas onto the street.The source of this aroma is the coffee shop of Domenico Barbera,',
                                    size: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white54),
                              ),
                              SizedBox(height: 40),
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
                                                  MenuBarberaCafe(),
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
                                                  BarberaBooking(),
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
                                      hotBarberaCafeCard(
                                          'assets/shop/barbera/shop1.jpg',
                                          'AMERICA',
                                          '18 Tourist Place',
                                          context),
                                      hotBarberaCafeCard(
                                          'assets/shop/barbera/shop3.jpg',
                                          'JAPAN',
                                          '18 Tourist Place',
                                          context),
                                      hotBarberaCafeCard(
                                          'assets/shop/barbera/shop5.jpg',
                                          'NEWYORK',
                                          '18 Tourist Place',
                                          context),
                                      hotBarberaCafeCard(
                                          'assets/shop/barbera/shop8.jpg',
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

  Widget hotBarberaCafeCard(String imagePath, String placeName,
      String touristPlaceCount, BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BarberaCafe(imagePath)))
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
}

class BarberaCafePageEnterAnimation {
  BarberaCafePageEnterAnimation(this.controller)
      : barHeight = Tween<double>(begin: 0, end: 600).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0, 0.5),
          ),
        );

  final AnimationController controller;
  final Animation<double> barHeight;
}
