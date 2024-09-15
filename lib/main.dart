// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:erbilcafe/Routing.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();

  runApp(Routing());
}
