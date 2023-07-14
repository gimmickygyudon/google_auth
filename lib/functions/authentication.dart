import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:google_auth/strings/user.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase() async {
    final firebaseApp = await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;

    // User already Logged In
    if (user != null) {
      debugPrint(user.displayName);
    }

    // TODO: Google Authentication
    // Authentication.signOutGoogle();
    return firebaseApp;
  }

  static Future<Map?> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? loginSession = prefs.getString('Login Session');
    Map? jsonData;

    if (loginSession != '{}' && loginSession != null) {
      jsonData = jsonDecode(loginSession);

      currentUser = currentUserFormat(
        id_ousr: jsonData?['id_ousr'],
        login_type: jsonData?['login_type'],
        user_email: jsonData?['user_email'],
        user_name: jsonData?['user_name'],
        phone_number: jsonData?['phone_number'],
        user_password: jsonData?['user_password']
      );
    }
    return jsonData;
  }

  static Future<void> signIn(Map<String, dynamic> source) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Login Session', jsonEncode(source));
    currentUser = source;
    debugPrint('Login Session: $source');
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    initializeUser().then((value) {
      value?.containsValue('Google');
      signOutGoogle();
    });

    prefs.remove('Login Session');
    currentUser.clear();
    debugPrint('Sign Out Session Deleted');
  }

  static Future<User?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

     // if it's a Web Browser
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signIn().then((value) async {
        if (value != null) {
          final GoogleSignInAuthentication googleSignInAuthentication = await value.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          try {
            final UserCredential userCredential = await auth.signInWithCredential(credential);

            user = userCredential.user;
          } on FirebaseAuthException catch (e) {
            if (e.code == 'account-exists-with-different-credential') {
              debugPrint('The account already exists with a different credential');
            }
            else if (e.code == 'invalid-credential') {
              debugPrint('Error occurred while accessing credentials. Try again.');
            }
          } catch (e) {
              debugPrint('Error occurred using Google Sign In. Try again.');
              return null;
          }
        }
        return null;
      });
    }

    return user;
  }

  static Future<void> signOutGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error signing out. Try again.');
    }
  }
}
