import 'dart:ui';

import 'package:erbilcafe/src/ShopScreen/StorePart/BarberaCafe/menu.dart';
import 'package:erbilcafe/src/ShopScreen/StorePart/NazdarhairanCafe/NazdarhairanCafe.dart';
import 'package:erbilcafe/src/ShopScreen/StorePart/alreef/Alreef_Cafe.dart';

import 'package:erbilcafe/src/ShopScreen/shop_list_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';

import 'StorePart/BarberaCafe/Barbera_Cafe.dart';

class HotelListView extends StatelessWidget {
  const HotelListView(
      {Key? key,
      this.hotelData,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final VoidCallback? callback;
  final HotelListData? hotelData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: InkWell(
                splashColor: Colors.black,
                onTap: () {
                  if (hotelData!.titleTxt == 'Barbera Cafe')
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            BarberaCafe("assets/shop/barbera/shop2.jpg"),
                      ),
                    );
                  else if (hotelData!.titleTxt == 'Nazdar Heyran Cafe')
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            NazdarHairan("assets/shop/nazdar/n1.jpg"),
                      ),
                    );
                  else if (hotelData!.titleTxt == 'Alreef Cafe')
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AlreefCafe("assets/shop/alreef/a8.jpg"),
                      ),
                    );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 2,
                              child: Image.asset(
                                hotelData!.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              color: HexColor('#141921'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      // color: HexColor('#141921'),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, top: 8, bottom: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              hotelData!.titleTxt,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 22,
                                                  color: HexColor('#E6CCB2')),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  hotelData!.subTxt,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: HexColor('#E6CCB2')
                                                          .withOpacity(0.8)),
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Icon(
                                                    FontAwesomeIcons
                                                        .mapMarkerAlt,
                                                    size: 12,
                                                    color: HexColor('#d17842')),
                                                Expanded(
                                                  child: Text(
                                                    '${hotelData!.dist.toStringAsFixed(1)} km to city',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: HexColor(
                                                                '#E6CCB2')
                                                            .withOpacity(0.8)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: <Widget>[
                                                  RatingBar(
                                                    initialRating:
                                                        hotelData!.rating,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 24,
                                                    ratingWidget: RatingWidget(
                                                      full: Icon(
                                                          Icons
                                                              .star_rate_rounded,
                                                          color: HexColor(
                                                              '#d17842')),
                                                      half: Icon(
                                                          Icons
                                                              .star_half_rounded,
                                                          color: HexColor(
                                                              '#d17842')),
                                                      empty: Icon(
                                                          Icons
                                                              .star_border_rounded,
                                                          color: HexColor(
                                                              '#d17842')),
                                                    ),
                                                    itemPadding:
                                                        EdgeInsets.zero,
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                  Text(
                                                    ' ${hotelData!.reviews} Reviews',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: HexColor(
                                                            '#E6CCB2')),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(32.0),
                              ),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.favorite_border,
                                    color: HexColor('#d17842')

                                    //  HotelAppTheme.buildLightTheme()
                                    // .primaryColor,
                                    ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
