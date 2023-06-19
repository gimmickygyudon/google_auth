// ignore_for_file: non_constant_identifier_names

import 'package:async/async.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_auth/functions/sql_client.dart';

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
      'subdistrict': subdistrict
    };
  }
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

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


class LocationName {


  static AsyncMemoizer<List<String>> provinceMemorizer = AsyncMemoizer();

  static Future<List<String>> getProvince() async {
    return provinceMemorizer.runOnce(() {
      return SQL.retrieveAll(api: 'sim/oprv').then((value) {
        List<String> province() {
          return value.map<String>((element) {
            return element['province_name'];
          }).toList();
        }

        return province();
      });
    });
  }

}