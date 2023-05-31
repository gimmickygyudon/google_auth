import 'package:flutter/material.dart';

import '../routes/login_page.dart';
import '../routes/register_page.dart';

void pushLogin(BuildContext context, [Map? source, String? from]) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRoute(source: source, from: from)));
}

void pushRegister(BuildContext context, String logintype_, [String? value]) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterRoute(phonenumber: value, logintype_: logintype_)));
}

void pushRegisterGoogle(BuildContext context, String logintype_, Map? source) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterRoute(logintype_: logintype_, source: source)));
}