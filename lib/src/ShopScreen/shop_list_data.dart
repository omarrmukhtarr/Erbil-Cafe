class HotelListData {
  HotelListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.subTxt = "",
    this.dist = 1.8,
    this.reviews = 80,
    this.rating = 4.5,
    this.perNight = 180,
  });

  String imagePath;
  String titleTxt;
  String subTxt;
  double dist;
  double rating;
  int reviews;
  int perNight;

  static List<HotelListData> hotelList = <HotelListData>[
    HotelListData(
      imagePath: 'assets/shop/alreef/a1.jpg',
      titleTxt: 'Alreef Cafe',
      subTxt: 'Kurdistan, Erbil',
      dist: 2.0,
      reviews: 80,
      rating: 4.4,
      perNight: 180,
    ),
    HotelListData(
      imagePath: 'assets/shop/barbera/shop1.jpg',
      titleTxt: 'Barbera Cafe',
      subTxt: 'Kurdistan, Erbil',
      dist: 2.0,
      reviews: 80,
      rating: 4.4,
      perNight: 180,
    ),
    HotelListData(
      imagePath: 'assets/shop/nazdar/n1.jpg',
      titleTxt: 'Nazdar Heyran Cafe',
      subTxt: 'Kurdistan, Erbil',
      dist: 2.0,
      reviews: 80,
      rating: 4.4,
      perNight: 180,
    ),
    HotelListData(
      imagePath: 'assets/shop/barbera/shop3.jpg',
      titleTxt: 'Barbera Cafe',
      subTxt: 'Kurdistan, Erbil',
      dist: 2.0,
      reviews: 80,
      rating: 4.4,
      perNight: 180,
    ),
  ];
}

// class ShoplListData {
//   ShoplListData({
//     this.imagePath = '',
//     this.titleTxt = '',
//     this.subTxt = "",
//     this.dist = 1.8,
//     this.reviews = 80,
//     this.rating = 4.5,
//     this.perNight = 180,
//   });

//   String imagePath;
//   String titleTxt;
//   String subTxt;
//   double dist;
//   double rating;
//   int reviews;
//   int perNight;

//   static List<ShopListData> ShopList = <ShopListData>[
//    ShopListData(
//       imagePath: 'assets/shop/shop2.jpg',
//       titleTxt: 'Alreef Cafe',
//       subTxt: 'Kurdistan, Erbil',
//       dist: 2.0,
//       reviews: 80,
//       rating: 4.4,
//       perNight: 180,
//     ),
//   ];
// }