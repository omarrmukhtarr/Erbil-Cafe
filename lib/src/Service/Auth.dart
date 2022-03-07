import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';




class AuthServise {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign In anonymouse
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
