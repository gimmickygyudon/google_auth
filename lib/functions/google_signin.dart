import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/snackbar.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase({required BuildContext context, required Function pushLogin}) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) { 
       pushLogin();
    }

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context, required Function pushLogin}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    
    // can't include BuildContext inside async gaps
    void showSnackBar_(content, [bool progress = false]) {
      showSnackBar(context, progress ? snackBarAuthProgress(context, content) : snackBarAuth(context, content)); 
    }

    void hideSnackBar_() {
      hideSnackBar(context);
    }

    // if it's a web browser
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        debugPrint(e.toString());
      } finally {
        pushLogin();
        showSnackBar_('Masuk sebagai ${user!.displayName}.');
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
            showSnackBar_('Signing in...', true);
            final UserCredential userCredential = await auth.signInWithCredential(credential);

            user = userCredential.user;
          } on FirebaseAuthException catch (e) {
            if (e.code == 'account-exists-with-different-credential') {
              showSnackBar_('The account already exists with a different credential');
            }
            else if (e.code == 'invalid-credential') {
              showSnackBar_('Error occurred while accessing credentials. Try again.');
            }
          } catch (e) {
              showSnackBar_('Error occurred using Google Sign In. Try again.');
              return null;
          } finally {
            hideSnackBar_();
            pushLogin();
            showSnackBar_('Masuk sebagai ${user!.displayName}.');
          }
        }
        return null;
      });
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context, required Function pushLogout}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // can't include BuildContext inside async gaps
    void showSnackBar_(content, [bool progress = false]) {
      showSnackBar(context, progress ? snackBarAuthProgress(context, content) : snackBarAuth(context, content)); 
    }

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      showSnackBar_('Signing out...', true);
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showSnackBar_('Error signing out. Try again.');
    }
    finally { 
      hideSnackBar(context);
      pushLogout(); 
      showSnackBar_('Berhasil Keluar.');
    }
  }
}
