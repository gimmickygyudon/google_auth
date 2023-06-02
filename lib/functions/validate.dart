import 'package:flutter/material.dart';

import '../widgets/dialog.dart';
import 'push.dart';
import 'sqlite.dart';

class InputForm {

  static bool validate(bool condition) {
    bool isValidated = false;
    if (condition) {
      isValidated = true;
    } else { isValidated = false; }
    return isValidated;
  }

  static void checkUser({
    required BuildContext context, 
    Map? source, 
    required String logintype,
    required String user
  }) {
    UserRegister.retrieve(user).then((item) {
      if (item.isNotEmpty) { 
        Map<String, dynamic> source = {
          'user_email': item.last.user_email,
          'user_name': item.last.user_name,
          'phone_number': item.last.phone_number
        };
        showRegisteredUser(context, source, pushLogin, 'Nomor');
      } else {
        switch (logintype) {
          case 'Email':
            pushRegister(context, logintype, user);
            break;
          case 'Nomor':
            pushRegister(context, logintype, user);
            break;
          case 'Nomor':
            pushRegister(context, logintype_, value);
            break;
          case 'Google':
            pushRegisterGoogle(context, logintype, source);
            break;
          default:
        }
      }
    });
  }
}
