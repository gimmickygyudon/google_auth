import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/routes/belanja/checkout.dart';
import 'package:google_auth/routes/belanja/detail_item.dart';
import 'package:google_auth/routes/belanja/item.dart';
import 'package:google_auth/routes/belanja/orders_page.dart';
import 'package:google_auth/routes/beranda/customer.dart';
import 'package:google_auth/routes/keluhan/report_page.dart';
import 'package:google_auth/routes/alamat/address.dart';
import 'package:google_auth/routes/start_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes/dashboard.dart';
import '../routes/login_page.dart';
import '../routes/alamat/add_address.dart';
import '../routes/register_page.dart';

PageRouteBuilder transitionShared({
  required Duration duration,
  required Duration reverseDuration,
  required SharedAxisTransitionType transitionType,
  required Widget page
}) {
  return PageRouteBuilder(
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: transitionType,
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    }
  );
}

PageRouteBuilder transitionFadeThrough({
  required Duration duration,
  required Duration reverseDuration,
  required Widget page
}) {
  return PageRouteBuilder(
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    }
  );
}

PageRouteBuilder transitionScaleFade({
  required Duration duration,
  required Duration reverseDuration,
  required Widget page
}) {
  return PageRouteBuilder(
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeScaleTransition(
        animation: animation,
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    }
  );
}

void pushStart(BuildContext context, {Map? source, String? logintype}) {
  Navigator.pushReplacement(context, transitionScaleFade(
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 200),
    page: const StartPageRoute()
  ));
}

void pushLogin(BuildContext context, {Map? source, String? logintype}) {
  Navigator.push(context, transitionShared(
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 200),
    transitionType: SharedAxisTransitionType.horizontal,
    page: LoginRoute(source: source, logintype: logintype)
  ));
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
  Navigator.pushReplacement(context, transitionFadeThrough(
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 500),
    page: DashboardRoute(currentPage: currentPage)
  ));
}

void pushAddCustomer(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return const AddCustomerRoute();
    })
  );
}

void pushReportPage({required BuildContext context, Map? laporan, required List<Map> laporanList}) {
  Navigator.push(context, transitionShared(
    duration: const Duration(milliseconds: 600),
    reverseDuration: const Duration(milliseconds: 200),
    transitionType: SharedAxisTransitionType.vertical,
    page: LaporanRoute(laporan: laporan, laporanList: laporanList)));
}

void pushItemPage({
    required BuildContext context,
    required List<Map> items,
    required String brand, hero, background, logo,
    required Color color,
  }) {
  Navigator.push(context, transitionShared(
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 400),
    transitionType: SharedAxisTransitionType.vertical,
    page: ItemRoute(items: items, hero: hero, background: background, color: color, logo: logo, brand: brand)
  ));
}

void pushItemDetailPage({
  required BuildContext context,
  required String brand, hero,
  required Color color,
  required Map item
}) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return DetailItemRoute(hero: hero, color: color, item: item, brand: brand);
    })
  );
}

void pushItemDetailPageReplace({
  required BuildContext context,
  required String brand, hero,
  required Color color,
  required Map item,
  required String type
}) {
  Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (context) {
      return DetailItemRoute(hero: hero, color: color, item: item, brand: brand, type: type);
    })
  );
}

Future<void> launchURL({required String url}) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

void pushOrdersPage({required BuildContext context, required String hero}) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return OrdersPageRoute(hero: hero);
    })
  );
}

void pushAddress({
  required BuildContext context,
  required String hero,
}) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return AddressRoute(hero: hero);
    })
  );
}

void pushAddressReplacement({
  required BuildContext context,
  required String hero,
}) {
  Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (context) {
      return AddressRoute(hero: hero);
    })
  );
}

void pushAddressAdd({
  required BuildContext context,
  required String hero
}) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return AddressAddRoute(hero: hero);
    })
  );
}

void pushAddressAddReplacement({
  required BuildContext context,
  required String hero
}) {
  Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (context) {
      return AddressAddRoute(hero: hero);
    })
  );
}

void pushCheckout({
  required BuildContext context,
  required List<bool> checkedItems
}) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return CheckoutRoute(checkedItems: checkedItems);
    })
  );
}