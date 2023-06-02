import 'package:flutter/material.dart';
import 'package:google_auth/widgets/snackbar.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../widgets/dialog.dart';
import 'push.dart';
import 'sqlite.dart';

class InputForm {

  static void signin(BuildContext context, {required String logintype, required Map source}) {
    pushDashboard(context, loginWith: logintype, source: source);
  }

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
    bool? skipDialog, bool? login, String? photo,
    String? password
  }) {
    UserRegister.retrieve(user).then((item) async {
      if (item.isNotEmpty) { 
        Map<String, dynamic> source = {
          'user_email': item.last.user_email,
          'user_name': item.last.user_name,
          'phone_number': item.last.phone_number
        };
        if (photo != null) {
          Map<String, dynamic> photourl = { 'photo_url': photo };
          source.addAll(photourl);
        }
        if (login == true ) {
          if (await InputForm.checkPassword(context, user: user, password: password!)) {
            signin(context, logintype: logintype, source: source);
          }
        } else {
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
