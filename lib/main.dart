// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:erbilcafe/Routing.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();

  // Initialize Google Maps with error handling
  try {
    // Google Maps will be initialized automatically when needed
    print('App initialized successfully');
  } catch (e) {
    print('Initialization error: $e');
    // Continue if initialization fails
  }

  runApp(Routing());
}
