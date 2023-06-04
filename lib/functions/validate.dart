import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:google_auth/functions/authentication.dart';
import 'package:google_auth/widgets/snackbar.dart';
import '../strings/user.dart';
import '../widgets/dialog.dart';
import 'push.dart';
import 'sql_client.dart';
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

  static Future<bool> checkPassword(BuildContext context, {required Map item, required String password}) async {
    String string = 'Kata Sandi Salah';
    String passwordMD5 = md5.convert(utf8.encode(password)).toString();
    if (passwordMD5 == item['user_password']) {
      return true;
    } else {
      hideSnackBar(context);
      showSnackBar(context, snackBarAuth(context: context, content: string));
      return false;
    }
  }

  static Future<void> checkUser({
    required BuildContext context, 
    Map? source, 
    required String logintype,
    required String user,
    bool? skipDialog, bool? login,
    String? password
  }) async {

    void pushDashboard_({required Map source}) => pushDashboard(context);

    String? photourl; 
    String query() => EmailValidator.validate(user) ? 'user_email' : 'phone_number';
    if(source != null) photourl = source.containsKey('photo_url') ? source['photo_url'] : null;

    // TODO: retrieve still using local database
    SQL.retrieve(query: query(), api: 'ousr', value: user).then((item) async {
      if (item.isNotEmpty) {
        if (login == true) {
          if (await Validate.checkPassword(context, item: item, password: password!)) {
            currentUser = currentUserFormat(
              id_ousr: item['id_ousr'], 
              login_type: logintype, 
              user_email: item['user_email'], 
              user_name: item['user_name'], 
              phone_number: item['phone_number'],
              user_password: item['user_password']
            );
            Authentication.signIn(currentUser).whenComplete(() => pushDashboard_(source: currentUser));
          }
        } else {
          Map<String, dynamic> source = {
            'user_name': item['user_name'],
            'user_email': item['user_email'],
            'phone_number': item['phone_number'],
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
