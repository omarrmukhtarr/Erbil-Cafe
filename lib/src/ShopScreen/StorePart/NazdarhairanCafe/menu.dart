import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class NazdarMenu extends StatelessWidget {
  const NazdarMenu({Key? key}) : super(key: key);
  static var screenHeight;
  static var screenWidth;
  Widget buildSingleItem({
    images,
    title,
    price,
    context,
    rating,
  }) {
    return Container(
      width: 190,
      height: 200,
      margin: EdgeInsets.only(right: 5, left: 10, top: 10, bottom: 10),
      padding: EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xff17191f),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                        color: Color(0xff30221f),
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(images),
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "\IQD\t",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffd17842)),
                            ),
                            Text(
                              "$price",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 25,
                            color: Color(0xffd17842),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 23.0,
            width: 55.0,
            decoration: BoxDecoration(
              color: Color(0xff231715),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(15.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: Color(0xffd17842),
                ),
                Text(
                  "$rating",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: HexColor('#E6CCB2'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      'Cold Coffee',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 20,
                thickness: 3,
                color: Colors.black,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m1.jpg",
                        title: "Esspreso Shakerato",
                        price: 5000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m2.jpg",
                        title: "Esspreso Fredo",
                        price: 5000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m3.jpg",
                        title: "Esspreso Frappe",
                        price: 5000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m4.jpg",
                        title: "Affogato",
                        price: 5000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m5.jpg",
                        title: "Esspreso Freddo",
                        price: 4000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m6.jpg",
                        title: "Magic Frozen",
                        price: 4000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m7.jpg",
                        title: "Cappuccino Frappe",
                        price: 6000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m8.jpg",
                        title: "Cappuccino Shakerato",
                        price: 6000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m9.jpg",
                        title: "Mocha Frappe",
                        price: 6000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m10.jpg",
                        title: "Oreo frappe",
                        price: 6000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m11.jpg",
                        title: "Caramel frappe",
                        price: 6000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m11.jpg",
                        title: "Cappuccino",
                        price: 4000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      'Hot Coffee',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 20,
                thickness: 3,
                color: Colors.black,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m13.jpg",
                        title: "Esspreso Italiano",
                        price: 3000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m14.jpg",
                        title: "Double Esspreso ",
                        price: 5000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m15.jpg",
                        title: "Esspreso Machiato",
                        price: 4000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m16.jpg",
                        title: "Cappuccino Napoletano",
                        price: 4500,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m17.jpg",
                        title: "Caffe Latte",
                        price: 5000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m18.jpg",
                        title: "Cappuccino Italiano",
                        price: 4000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m19.jpg",
                        title: "Hot Chocalate",
                        price: 5000,
                        rating: 4.5,
                      ),
                      buildSingleItem(
                        context: context,
                        images: "assets/shop/menu/m20.jpg",
                        title: "Americano",
                        price: 4000,
                        rating: 4.5,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
