import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:google_auth/functions/authentication.dart';
import 'package:google_auth/widgets/snackbar.dart';
import '../strings/user.dart';
import '../widgets/dialog.dart';
import 'push.dart';
import 'sqlite.dart';

class Validate {

  static bool validate(bool condition) {
    bool isValidated = false;
    if (condition) {
      isValidated = true;
    } else { 
      isValidated = false; 
    }
    return isValidated;
  }

  static Future<bool> checkPassword(BuildContext context, {required String user, required String password}) async {
    String string = 'Kata Sandi Salah';
    bool value = await UserRegister.retrieve(user).then((item) {
      String passwordMD5 = md5.convert(utf8.encode(password)).toString();
      if (passwordMD5 == item.last.user_password) {
        return true;
      } else {
        hideSnackBar(context);
        showSnackBar(context, snackBarAuth(context: context, content: string));
        return false;
      }
    });
    return value;
  }

  static void checkUser({
    required BuildContext context, 
    Map? source, 
    required String logintype,
    required String user,
    bool? skipDialog, bool? login,
    String? password
  }) {

    void pushDashboard_({required Map source}) {
      pushDashboard(context);
    }

    String? photourl; 
    if(source != null) photourl = source.containsKey('photo_url') ? source['photo_url'] : null;

    // TODO: retrieve still using local database
    UserRegister.retrieve(user).then((item) async {
      if (item.isNotEmpty) { 
        if (login == true) {
          if (await Validate.checkPassword(context, user: user, password: password!)) {
            currentUser = currentUserFormat(
              id_ousr: item.last.id_ousr, 
              login_type: logintype, 
              user_email: item.last.user_email, 
              user_name: item.last.user_name, 
              phone_number: item.last.phone_number, 
              user_password: item.last.user_password
            );
            Authentication.signIn(currentUser).whenComplete(() => pushDashboard_(source: currentUser));
          }
        } else {
          Map<String, dynamic> source = {
            'user_name': item.last.user_name,
            'user_email': item.last.user_email,
            'phone_number': item.last.phone_number,
          };
          if (photourl != null) source.addAll({'photo_url': photourl});
          pushLogin(context, source: source, logintype: logintype);
        }

      } else {
        void showRegister(Function callback, String from) {
          showUnRegisteredUser(context, 
            value: user, 
            callback: callback, 
            from: from,
            source: source
          );
        }
        switch (logintype) {
          case 'Email':
            void pushRegister_() => pushRegister(context, logintype, user, source);
            if (skipDialog == true) {
              pushRegister_();
            } else { showRegister(pushRegister_, logintype); }
            break;
          case 'Nomor':
            void pushRegister_() => pushRegister(context, logintype, user, source);
            if (skipDialog == true) {
              pushRegister_();
            } else { showRegister(pushRegister_, logintype); }
            break;
          case 'Google':
            void pushRegister_() => pushRegisterGoogle(context, logintype, source);
            if (skipDialog == true) {
              pushRegister_();
            } else { showRegister(pushRegister_, logintype); }
            break;
          default:
        }
      }
    });
  }
}
