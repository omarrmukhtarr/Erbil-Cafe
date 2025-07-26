// import 'package:firebase_auth/firebase_auth.dart';

class AuthServise {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign In anonymouse
  Future signInAnon() async {
    try {
      // UserCredential result = await _auth.signInAnonymously();
      // User? user = result.user;
      print("Firebase auth temporarily disabled");
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
