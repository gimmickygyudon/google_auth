// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:async/async.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_auth/functions/sql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/belanja/orders_page.dart';

class UserLocation {
  final String? name;
  final String? street;
  final String? iso_country;
  final String? country;
  final String? postal_code;
  final String? province;
  final String? district;
  final String? subdistrict;
  final String? suburb;

  const UserLocation({
    required this.name,
    required this.street,
    required this.iso_country,
    required this.country,
    required this.postal_code,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.suburb
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'street': street,
      'iso_country': iso_country,
      'country': country,
      'postal_code': postal_code,
      'province': province,
      'district': district,
      'subdistrict': subdistrict,
      'suburb': suburb
    };
  }
  static Future<Position> determinePosition() async {
    // bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return currentLocation;
  }


  static AsyncMemoizer<UserLocation> placemarkMemoizer = AsyncMemoizer();

  static Future<UserLocation> defineLocationName(Position currentLocation) async {
    return placemarkMemoizer.runOnce(() async {
      UserLocation userLocation = await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((value) {
        String combinedStreet() {
          return value.map((placemark) {
            if (placemark.street != 'Jalan Tanpa Nama' && placemark.street != null) {
              return placemark.street;
            }
          }).nonNulls.toList().join(', ');
        }

        UserLocation placemark = UserLocation(
          name: value.first.name,
          street: combinedStreet(),
          iso_country: value.first.isoCountryCode,
          country: value.first.country,
          postal_code: value.first.postalCode,
          province: value.first.administrativeArea,
          district: value.first.subAdministrativeArea,
          subdistrict: value.first.locality,
          suburb: value.first.subLocality
        );

        return placemark;
      });

      return userLocation;
    });
  }

  static Future<UserLocation> redefineLocationName(Position currentLocation) async {
    UserLocation userLocation = await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((value) {
        String combinedStreet() {
          return value.map((placemark) {
            if (placemark.street != 'Jalan Tanpa Nama' && placemark.street != null) {
              return placemark.street;
            }
          }).nonNulls.toList().join(', ');
        }

        UserLocation placemark = UserLocation(
          name: value.first.name,
          street: combinedStreet(),
          iso_country: value.first.isoCountryCode,
          country: value.first.country,
          postal_code: value.first.postalCode,
          province: value.first.administrativeArea,
          district: value.first.subAdministrativeArea,
          subdistrict: value.first.locality,
          suburb: value.first.subLocality
        );

        return placemark;
      });

    return userLocation;
  }
}

class Delivery {
  static Future<void> setType(String type) async {
    final prefs = await SharedPreferences.getInstance();

    OrdersPageRoute.delivertype.value = type;
    prefs.setString('delivery_type', type);
  }

  static Future<String> getType() async {
    final prefs = await SharedPreferences.getInstance();

    String? type = prefs.getString('delivery_type');
    if (type == null) {
      return 'FRANCO';
    } else {
      return type;
    }
  }
}

class LocationManager {
  final String name;
  final String phone_number;
  final String province;
  final String district;
  final String subdistrict;
  final String suburb;
  final String street;

  const LocationManager({
    required this.name,
    required this.phone_number,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.suburb,
    required this.street
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone_number': phone_number,
      'street': street,
      'province': province,
      'district': district,
      'subdistrict': subdistrict,
      'suburb': suburb
    };
  }


  static Future<void> set(List source) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('location', jsonEncode(source));
  }

  static Future<void> add(Map source) async {
    List? location = await retrieve().then((value) {
      List? location = value;
      location?.add(source);

      return location;
    });

    if (location != null) {
      set(location);
    } else {
      set([source]);
      setIndex(0);
    }
  }

  static Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('location');
  }

  static Future<void> delete(int i) async {
    retrieve().then((value) {
      List? element = value;

      element?.removeAt(i);
      if (element != null) {
        set(element);
        getIndex().then((index) {
          if (i == index) setIndex(element.length - 1);
        });
      }
    });
  }

  static Future<List?> retrieve() async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonData = prefs.getString('location');
    List? items;

    if(jsonData != null) {
      items = jsonDecode(jsonData);
    }

    return items;
  }

  static Future<void> setIndex (int index) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('location_index', index);
  }

  static Future<int?> getIndex() async {
    final prefs = await SharedPreferences.getInstance();

    int? index = prefs.getInt('location_index');
    if (index != null) {
      if (index < 0) {
        index = 0;
      }
    }

    return index;
  }

  static Future<Map?> getCurrentLocation() async {
    return LocationManager.retrieve().then((value) async {
      return await getIndex().then((index) {
        if (index != null) return value?[index];

        return Future.error('Current Location Not Found');
      });

    });
  }

}

class LocationName {
  static AsyncMemoizer<List<Map>> provinceMemorizer = AsyncMemoizer();
  static AsyncMemoizer<List<Map>> districMemorizer = AsyncMemoizer();
  static AsyncMemoizer<List<Map>> subdistricMemorizer = AsyncMemoizer();
  static AsyncMemoizer<List<Map>> suburbMemorizer = AsyncMemoizer();

  static List<String?> selectedLocationName = List.filled(5, null, growable: false);

  static Future<List<Map>> getProvince() async {
    return provinceMemorizer.runOnce(() {
      return SQL.retrieveAll(api: 'sim/oprv').then((value) {

        return value;
      });
    });
  }

  static Future<List<String>> filterProvince() {
    return getProvince().then((province) {
      return province.map<String>((element) {

        return element['province_name'];
      }).nonNulls.toList();
    });
  }

  static Future<List<Map>> getDistrict() async {
    return districMemorizer.runOnce(() {
      return SQL.retrieveAll(api: 'sim/octy').then((value) {

        return value;
      });
    });
  }

  static Future<List<String>> filterDistrict() async {
    return getProvince().then((value) {
      return value.where((element) => element['province_name'] == selectedLocationName[0]).single;
    })
    .then((value) {
      return SQL.retrieve(api: 'sim/octy', query: 'id_oprv=${value['id_oprv']}')
      .then((value) {
        List<String>? strings = List.empty(growable: true);
        value.map((element) {
          return strings.add(element['city_name']);
        }).toList();

        return strings;
      });
    });
  }

  static Future<List<Map>> getSubdistrict() async {
    return subdistricMemorizer.runOnce(() {
      return SQL.retrieveAll(api: 'sim/osdt').then((value) {

        return value;
      });
    });
  }

  static Future<List<String>> filterSubdistrict() async {
    return getDistrict().then((value) {
      return value.where((element) => element['city_name'] == selectedLocationName[1]).single;
    })
    .then((value) {
      return SQL.retrieve(api: 'sim/osdt', query: 'id_octy=${value['id_octy']}')
      .then((value) {
        List<String>? strings = List.empty(growable: true);
        value.map((element) {
          return strings.add(element['sub_district_name']);
        }).toList();

        return strings;
      });
    });
  }

  static Future<List<Map>> getSuburb() async {
    return suburbMemorizer.runOnce(() {
      return SQL.retrieveAll(api: 'sim/ovil').then((value) {

        return value;
      });
    });
  }

  static Future<List<String>> filterSuburb() async {
    return getSubdistrict().then((value) {
      return value.where((element) => element['sub_district_name'] == selectedLocationName[2]).single;
    })
    .then((value) {
      print('suburb: $value');
      return SQL.retrieve(api: 'sim/ovil', query: 'id_osdt=${value['id_osdt']}')
      .then((value) {
        List<String>? strings = List.empty(growable: true);
        value.map((element) {
          return strings.add(element['village_name']);
        }).toList();

        return strings;
      });
    });
  }
}