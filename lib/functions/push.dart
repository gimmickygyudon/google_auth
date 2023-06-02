import 'package:flutter/material.dart';

import '../routes/login_page.dart';
import '../routes/register_page.dart';

void pushLogin(BuildContext context, [Map? source, String? logintype]) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRoute(source: source, logintype: logintype)));
}

void pushRegister(BuildContext context, String logintype_, [String? value]) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterRoute(phonenumber: value, logintype: logintype_)));
}

void pushRegisterGoogle(BuildContext context, String logintype_, Map? source) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterRoute(logintype: logintype_, source: source)));
}
