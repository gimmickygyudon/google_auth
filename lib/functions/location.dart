// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_auth/functions/sql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/alamat/address.dart';
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

  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.requestPermission()
    .then((permission) async {
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        // Test if location services are enabled.
        Geolocator.isLocationServiceEnabled();
        // if (!serviceEnabled) {
        //   // Location services are not enabled don't continue
        //   // accessing the position and request users of the
        //   // App to enable the location services.
        //   return Future.error('Tidak dapat menghubungi layanan GPS anda.');
        // }
        return permission;
      } else if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      } else {
        // Permissions are denied forever, handle appropriately.
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }
    });
  }

  static Future<Position> determinePosition() async {
    checkPermission();

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

class LocationManager extends ChangeNotifier {
  final String name;
  final String phone_number;
  final String? province;
  final String district;
  final String subdistrict;
  final String suburb;
  final String street;

  LocationManager({
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

  static Map<String, AsyncMemoizer<Map>> dataLocationMemoizer = {};

  static Future<Map>? getDataLocation({required String id}) {
    if (dataLocationMemoizer.containsKey(id) == true) {
      return dataLocationMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'usr1', query: 'id_usr1=$id').then((value) {
          return value;
        });
      });
    } else {
      dataLocationMemoizer.addAll({id: AsyncMemoizer<Map>()});
      return dataLocationMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'usr1', query: 'id_usr1=$id').then((value) {
          return value;
        });
      });
    }
  }

  static Future<List?> getLocalDataLocation() {
    return LocationManager.retrieve().then((value) {
      return LocationManager.getIndex().then((index) async {
        AddressRoute.locations.value['locationindex'] = index;
        OrdersPageRoute.delivertype.value = await Delivery.getType();
        return value;
      });
    });
  }

  static Future<List<int>> getLocationsId() async {
    Map? currentLocation;
    int id_oprv, id_octy, id_osdt, id_ovil;

    currentLocation = AddressRoute.locations.value['locations'][AddressRoute.locations.value?['locationindex']];
    id_oprv = await LocationName.getProvince().then((province) {
      return province.firstWhere((element) => element['province_name'] == currentLocation?['province'].toString().toUpperCase())['id_oprv'];
    });
    id_octy = await LocationName.getDistrict().then((district) {
      return district.firstWhere((element) => element['city_name'] == currentLocation?['district'].toString().toUpperCase())['id_octy'];
    });

    id_osdt = await LocationName.getSubdistrict().then((subdistrict) {
      String? currentSubdistrict = currentLocation?['subdistrict'].toString().toUpperCase().replaceAll('KECAMATAN', '').trim();
      return subdistrict.firstWhere((element) => element['sub_district_name'] == currentSubdistrict)['id_osdt'];
    });

    id_ovil = await LocationName.getSuburb().then((suburb) {
      return suburb.firstWhere((element) => element['village_name'] == currentLocation?['suburb'].toString().toUpperCase())['id_ovil'];
    });

    return [id_oprv, id_octy, id_osdt, id_ovil];
  }

  static Future<void> set(List source) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('location', jsonEncode(source));
  }

  static Future<void> add(Map source) async {
    List? location = await retrieve().then((value) {
      List? location = value;
      location?.add(source);
      AddressRoute.locations.value['locations'].add(source);
      if (AddressRoute.locations.value['locations'].length < 2) {
        AddressRoute.locations.value['locationindex'] = 0;
        setIndex(0);
      }
      AddressRoute.locations.notifyListeners();

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
      AddressRoute.locations.value['locations'].removeAt(i);
      AddressRoute.locations.notifyListeners();
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

    AddressRoute.locations.value['locationindex'] = index;
    AddressRoute.locations.notifyListeners();
    prefs.setInt('location_index', index);
  }

  static Future<int> getIndex() async {
    final prefs = await SharedPreferences.getInstance();

    int? index = prefs.getInt('location_index');
    if (index != null) {
      if (index < 0) {
        index = 0;
      }
    } else {
      index = 0;
    }

    return index;
  }

  static Future<Map?> getCurrentLocation() async {
    return LocationManager.retrieve().then((value) async {
      return await getIndex().then((index) {
        if (value != null) {
          if (value.isNotEmpty) {
            return value[index];
          }
        }

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
    })
    .onError((error, stackTrace) {
      return SQL.retrieveAll(api: 'sim/oprv');
    })
    .then((value) {
      if (value.isEmpty) {
        return SQL.retrieveAll(api: 'sim/oprv');
      } else {
        return value;
      }
    });
  }


  static Map<String, AsyncMemoizer<String>> provinceNameMemoizer = {};
  static Future<String?> getProvinceName({required String id}) async {
    if (provinceNameMemoizer.containsKey(id) == true) {
      return provinceNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/oprv', query: 'id_oprv=$id').then((value) {
          return value['province_name'];
        });
      });
    } else {
      provinceNameMemoizer.addAll({id: AsyncMemoizer<String>()});
      return provinceNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/oprv', query: 'id_oprv=$id').then((value) {
          return value['province_name'];
        });
      });
    }
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
    })
    .onError((error, stackTrace) {
      return SQL.retrieveAll(api: 'sim/oprv');
    })
    .then((value) {
      if (value.isEmpty) {
        return SQL.retrieveAll(api: 'sim/octy');
      } else {
        return value;
      }
    });
  }

  static Map<String, AsyncMemoizer<String>> districtNameMemoizer = {};
  static Future<String?> getDistrictName({required String id}) async {
    if (districtNameMemoizer.containsKey(id) == true) {
      return districtNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/octy', query: 'id_octy=$id').then((value) {
          return value['city_name'];
        });
      });
    } else {
      districtNameMemoizer.addAll({id: AsyncMemoizer<String>()});
      return districtNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/octy', query: 'id_octy=$id').then((value) {
          return value['city_name'];
        });
      });
    }
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
    })
    .onError((error, stackTrace) {
      return SQL.retrieveAll(api: 'sim/oprv');
    })
    .then((value) {
      if (value.isEmpty) {
        return SQL.retrieveAll(api: 'sim/osdt');
      } else {
        return value;
      }
    });
  }

  static Map<String, AsyncMemoizer<String>> subDistrictNameMemoizer = {};
  static Future<String?> getSubDistrictName({required String id}) async {
    if (subDistrictNameMemoizer.containsKey(id) == true) {
      return subDistrictNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/osdt', query: 'id_osdt=$id').then((value) {
          return value['sub_district_name'];
        });
      });
    } else {
      subDistrictNameMemoizer.addAll({id: AsyncMemoizer<String>()});
      return subDistrictNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/osdt', query: 'id_osdt=$id').then((value) {
          return value['sub_district_name'];
        });
      });
    }
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
    })
    .onError((error, stackTrace) {
      return SQL.retrieveAll(api: 'sim/oprv');
    })
    .then((value) {
      if (value.isEmpty) {
        return SQL.retrieveAll(api: 'sim/ovil');
      } else {
        return value;
      }
    });
  }

  static Map<String, AsyncMemoizer<String>> suburbNameMemoizer = {};
  static Future<String?> getSuburbName({required String id}) async {
    if (suburbNameMemoizer.containsKey(id) == true) {
      return suburbNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/ovil', query: 'id_ovil=$id').then((value) {
          return value['village_name'];
        });
      });
    } else {
      suburbNameMemoizer.addAll({id: AsyncMemoizer<String>()});
      return suburbNameMemoizer[id]?.runOnce(() {
        return SQL.retrieve(api: 'sim/ovil', query: 'id_ovil=$id').then((value) {
          return value['village_name'];
        });
      });
    }
  }

  static Future<List<String>> filterSuburb() async {
    return getSubdistrict().then((value) {
      return value.where((element) => element['sub_district_name'] == selectedLocationName[2]).single;
    })
    .then((value) {
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