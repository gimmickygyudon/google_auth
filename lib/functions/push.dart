import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/routes/start_page.dart';

import '../routes/dashboard.dart';
import '../routes/login_page.dart';
import '../routes/register_page.dart';

void pushStart(BuildContext context, { Map? source, String? logintype }) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return const StartPageRoute();
  }));
}

void pushLogin(BuildContext context, { Map? source, String? logintype }) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return LoginRoute(
      source: source, 
      logintype: logintype
    );
  }));
}

void pushLogout(BuildContext context) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginRoute()));
}

void pushRegister(BuildContext context, String logintype, [String? value, Map? source]) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return RegisterRoute(
      value: value, 
      logintype: logintype, 
      source: source
    );
  }));
}

void pushRegisterGoogle(BuildContext context, String logintype_, Map? source) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return RegisterRoute(
      logintype: logintype_, 
      source: source
    );
  }));
}

void pushDashboard(BuildContext context, { 
  User? user,
  Map? source,
  required String loginWith 
}) {
  Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (context) {
      return DashboardRoute(
        user: user, 
        source: source, 
        loginWith: loginWith
      );
    })
  ); 
}
