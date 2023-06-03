import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_auth/functions/authentication.dart';
import 'package:intl/intl.dart';

import 'package:google_auth/widgets/snackbar.dart';
import '../widgets/dialog.dart';
import 'push.dart';
import 'sqlite.dart';

class InputForm {

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
    UserRegister.retrieve(user).then((item) async {
      void pushDashboard_({required String logintype, required Map source}) {
        pushDashboard(context, loginWith: logintype, source: source);
      }

      if (item.isNotEmpty) { 
        Map<String, dynamic> source_ = {
          'user_email': item.last.user_email,
          'user_name': item.last.user_name,
          'phone_number': item.last.phone_number
        };
        // TODO: quick fix later
        if (source != null) if (source.containsKey('photo_url')) source_.addAll({'photo_url': source['photo_url']});

        if (login == true) {
          if (await InputForm.checkPassword(context, user: user, password: password!)) {
            // TODO: make currentUser global variable
            Map<String, dynamic> currentUser = {
              'id_olog': null,
              'date_time': DateFormat('y-MM-d H:m:ss').format(DateTime.now()),
              'form_sender': logintype,
              'remarks': source_['user_name'],
              'source': source_['user_email']
            };
            Authentication.signIn(source_).whenComplete(() => pushDashboard_(logintype: logintype, source: source_));
          }
        } else {
          pushLogin(context, source: source_, logintype: logintype);
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
