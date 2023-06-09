import 'package:flutter/material.dart';
import 'package:google_auth/routes/belanja/item.dart';
import 'package:google_auth/routes/beranda/customer.dart';
import 'package:google_auth/routes/keluhan/report_page.dart';
import 'package:google_auth/routes/start_page.dart';

import '../routes/dashboard.dart';
import '../routes/login_page.dart';
import '../routes/register_page.dart';

void pushStart(BuildContext context, {Map? source, String? logintype}) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return const StartPageRoute();
  }));
}

void pushLogin(BuildContext context, {Map? source, String? logintype}) {
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

void pushDashboard(BuildContext context, {int? currentPage}) {
  Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (context) {
      return DashboardRoute(currentPage: currentPage);
    })
  ); 
}

void pushAddCustomer(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return const AddCustomerRoute();
    })
  ); 
}

void pushReportPage({required BuildContext context, Map? laporan, required List<Map> laporanList}) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return LaporanRoute(laporan: laporan, laporanList: laporanList);
    })
  ); 
}

void pushItemPage({required BuildContext context, required List<Map> items, required String hero}) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return ItemRoute(items: items, hero: hero);
    })
  ); 
}