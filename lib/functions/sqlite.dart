// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/strings/user.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../strings/item.dart';
import 'sql_client.dart';

class UserLog {
  final int? id_olog;
  final String date_time;
  final String form_sender, remarks, source;
  final String id_ousr;

  const UserLog({
    this.id_olog,
    required this.date_time,
    required this.form_sender,
    required this.remarks,
    required this.source,
    required this.id_ousr,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_olog': id_olog,
      'date_time': date_time,
      'form_sender': form_sender,
      'remarks': remarks,
      'source': source,
      'id_ousr': id_ousr
    };
  }

  @override
  String toString() {
    return '{id_olog: $id_olog, date_time: $date_time, form_sender: $form_sender, remarks: $remarks, source: $source, id_ousr: $id_ousr}';
  }

  static Future<Database> initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    // print('sqlite(initializeDatabase): $databasesPath');
    String path = join(databasesPath, 'olog.db');
    Database database;

    // Check if the database exists
    await databaseExists(path).then((value) async => print(value));

    // if (exists) print('sqlite(initializeDatabase): file exists');
    database = await openDatabase(
      join(await getDatabasesPath(), 'olog.db'),
      singleInstance: true,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE olog(id_olog INTEGER PRIMARY KEY AUTOINCREMENT, date_time DATETIME, form_sender TEXT, remarks TEXT, source TEXT)',
        );
      },
      version: 1,
    );

    return database;
  }

  static Future<void> insert(UserLog user) async {
    return SQL.retrieve(api: 'ousr', query: 'user_email=${user.source}')
      .onError((error, stackTrace) {
        return error;
      })
      .then((value) {
        SQL.insert(item: user.toMap(), api: 'olog');
      });
  }

  static Future<List<UserLog>> retrieve([String? source]) async {
    final db = await UserLog.initializeDatabase();

    final List<Map<String, dynamic>> maps = await db.query('olog');

    if (source != null) {
      return maps.where((element) => element['source'] == source).map((item) {
        return UserLog(
          id_olog: item['id_olog'],
          date_time: item['date_time'],
          form_sender: item['form_sender'],
          remarks: item['remarks'],
          source: item['source'],
          id_ousr: item['id_ousr']
        );
      }).toList();
    } else {
      return List.generate(maps.length, (i) {
        return UserLog(
          id_olog: maps[i]['id_olog'],
          date_time: maps[i]['date_time'],
          form_sender: maps[i]['form_sender'],
          remarks: maps[i]['remarks'],
          source: maps[i]['source'],
          id_ousr: maps[i]['id_ousr']
        );
      });
    }
  }

  static Future<void> update(UserLog user) async {
    final db = await UserLog.initializeDatabase();

    await db.update(
      'olog',
      user.toMap(),
      where: 'id_olog = ?',
      whereArgs: [user.id_olog],
    );
  }

  static Future<void> delete(int id_olog) async {
    final db = await UserLog.initializeDatabase();

    await db.delete(
      'olog',
      where: 'id = ?',
      whereArgs: [id_olog],
    );
  }
}

class UserReport {
  final int? id_osfb;
  final String document_date;
  final int id_ousr;
  final String remarks;

  const UserReport({
    required this.id_osfb, 
    required this.document_date, 
    required this.id_ousr, 
    required this.remarks,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id_osfb': id_osfb,
      'document_date': document_date,
      'id_ousr': id_ousr,
      'remarks': remarks,
    };
  }
  
  @override
  String toString() {
    return '{id_ousr: $id_ousr, document_date: $document_date, id_ousr: $id_ousr, remarks: $remarks}';
  }

  static Future<List?> getList({
    int? limit,
    int? offset,
    Function? setCount
  }) async {
    List? tickets = await SQL.retrieveJoin(
      api: 'osfb', 
      query: 'id_ousr',
      limit: limit,
      offset: offset,
      setCount: setCount,
      param: currentUser['id_ousr'].toString(), 
    );

    return tickets;
  }
}

class UserReport1 {
  final int? id_sfb1;
  final String id_osfb;
  final String type_feed;
  final String description;

  const UserReport1({
    required this.id_sfb1,
    required this.id_osfb,
    required this.type_feed,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_sfb1': id_sfb1,
      'id_osfb': id_osfb,
      'type_feed': type_feed,
      'description': description,
    };
  }
  
  @override
  String toString() {
    return '{id_sfb1: $id_sfb1, id_osfb: $id_osfb, type_feed: $type_feed, description: $description}';
  }
}

class UserReport2 {
  final int? id_sfb2;
  final String id_osfb;
  final String type;
  final String file_name;
  final String file_type;

  const UserReport2({
    this.id_sfb2,
    required this.id_osfb,
    required this.type,
    required this.file_name,
    required this.file_type,
  });
  
  Map<String, String> toMap() {
    return {
      'id_sfb2': 'NULL',
      'id_osfb': id_osfb,
      'type': type,
      'file_name': file_name,
      'file_type': file_type,
    };
  }
  
  @override
  String toString() {
    return '{id_sfb2: $id_sfb2, id_osfb: $id_osfb, type: $type, file_name: $file_name, file_type: $file_type}';
  }
}


class UserRegister {
  final int? id_ousr;
  final String login_type;
  final String user_email, user_name, phone_number, user_password;

  const UserRegister({
    required this.id_ousr,
    required this.login_type,
    required this.user_email,
    required this.user_name,
    required this.phone_number,
    required this.user_password
  });

  Map<String, dynamic> toMap() {
    return {
      'id_ousr': id_ousr,
      'login_type': login_type,
      'user_email': user_email,
      'user_name': user_name,
      'phone_number': phone_number,
      'user_password': user_password
    };
  }

  @override
  String toString() {
    return '{id_ousr: $id_ousr, login_type: $login_type, user_email: $user_email, user_name: $user_name, phone_number: $phone_number, user_password: $user_password}';
  }

  static Future<Database> initializeDatabase() async {
    Database database;

    database = await openDatabase(
      join(await getDatabasesPath(), 'ousr.db'),
      singleInstance: true,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE ousr(id_ousr INTEGER PRIMARY KEY AUTOINCREMENT, login_type TEXT, user_email TEXT, user_name TEXT, phone_number TEXT, user_password TEXT)',
        );
      },
      version: 1,
    );

    return database;
  }

  static Future<Map> insert(UserRegister user) async {
    var userMap = user.toMap();
    userMap['user_password'] = md5.convert(utf8.encode(user.user_password)).toString();

    print('sqlite(insert): $userMap');
    
    await UserRegister.initializeDatabase().then((db) async {
      db.insert(
        'ousr',
        userMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    return userMap;
  }

  static Future<List<UserRegister>> retrieve([String? source]) async {
    final db = await UserRegister.initializeDatabase();

    final List<Map<String, dynamic>> maps = await db.query('ousr');

    if (source != null) {
      bool isEmail = EmailValidator.validate(source);
      String item = isEmail ? 'user_email' : 'phone_number';

      return maps.where((element) => element[item] == source).map((value) {
        return UserRegister(
          id_ousr: value['id_ousr'], 
          login_type: value['login_type'],
          user_email: value['user_email'], 
          user_name: value['user_name'], 
          phone_number: value['phone_number'], 
          user_password: value['user_password']
        );
      }).toList();
    } else {
      return List.generate(maps.length, (i) {
        return UserRegister(
          id_ousr: maps[i]['id_ousr'], 
          login_type: maps[i]['login_type'],
          user_email: maps[i]['user_email'], 
          user_name: maps[i]['user_name'], 
          phone_number: maps[i]['phone_number'], 
          user_password: maps[i]['user_password']
        );
      });
    }
  }
}

class Cart {
  final String name;
  final String brand;
  final String dimension; 
  final List<String> dimensions;
  final String weight;
  final List<String> weights;
  final String count;

  const Cart({
    required this.name,
    required this.brand,
    required this.dimension,
    required this.dimensions,
    required this.weight,
    required this.weights,
    required this.count
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'dimension': dimension,
      'dimensions': dimensions,
      'weight': weight,
      'weights': weights,
      'count': count
    };
  }

  @override
  String toString() {
    return '{name: $name, brand: $brand, dimension: $dimension, weight: $weight, count: $count}';
  }

  static Future<void> add(Map source) async {
    List? cartItems = await Cart.getItems().then((value) {
      List? elements = value;
      elements?.add(source);

      return elements;
    });

    if(cartItems != null) {
      Cart.update(cartItems);
    } else {
      Cart.update([source]);
    }
  }

  static Future<void> remove({required int index}) async {
    await Cart.getItems().then((value) {
      List? elements = value;
      elements?.removeAt(index);

      elements?.forEach((e) { 
        print(e['name']);
      });

      if (elements != null) Cart.update(elements);
    });
  }

  static Future<void> update(List source) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Cart', jsonEncode(source)).whenComplete(() => getItems());
  }

  static Future<void> removeAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('Cart');
  }

  static Future<List?> getItems() async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonData = prefs.getString('Cart');
    List? items;

    if (jsonData != null) {
      items = jsonDecode(jsonData);
      return items;
    } else {
      return items;
    }
  }
}

class Item {

  // TODO: Need Rework
  static Map<String, AsyncMemoizer<List?>> listMemoizer = 
  { 
    'Indostar': AsyncMemoizer<List?>(),
    'ECO': AsyncMemoizer<List?>() 
  };

  static Future<List?> getItems({required String brand}) {
    return listMemoizer[brand]!.runOnce(() {
      FutureOr<List?> list = fetchItems(brand: brand);
      return list;
    });
  }

  static FutureOr<List?> fetchItems({required String brand}) {
    String? param;
    switch (brand.toUpperCase()) {
      case 'INDOSTAR':
        param = '9,10,11,23,29,30';
        break;
      case 'ECO':
        param = '4,5,6,42,43,52';
      default:
    }

    return SQL.retrieveJoin(api: 'sim/brn1', param: param, query: 'id_brn1');
  }

  static String defineDimension(String value) {
    return value.replaceAll('IN ', '').replaceAll('PP', '').replaceAll('PM', '').replaceAll('BES', '').replaceAll('EC', '').trim();
  }

  static List splitDimension(String value) {
    String string = value.replaceAll('IN ', '').replaceAll('PP', '').replaceAll('PM', '').replaceAll('BES', '').replaceAll('EC', '').trim();
    return string.split(' x ');
  }

  static String defineWeight(dynamic value) {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    String s = value.toString().replaceAll(regex, '');
    s = double.parse(s).toStringAsFixed(1);

    return s;
  }
  
  // TODO: move this to strings.dart
  static const List<Map> recommenditems = [{
    'name': 'Indostar',
    'subitem': [ 
      {
        'name': 'Indostar Board',
        'img': 'assets/Indostar Board.png',
        'icon': 'assets/INDOSTAR LOGO POST.png',
        'type': [
          {
            'name': 'Board Imperial',
            'description': ItemDescription.imperial,
            'diff': ['Tebal']
          }, {
            'name': 'Board Matric',
            'description': ItemDescription.matric,
            'diff': ['Tebal']
          }, {
            'name': 'Board Square',
            'description': ItemDescription.square,
            'diff': ['Panjang']
          }
        ]
      }, {
        'name': 'Indostar Bes',
        'img': 'assets/Indostar Bes.png',
        'icon': 'assets/Logo IndostarBes.png',
        'type': [
          {
            'name': 'Gelombang 14',
            'description': ItemDescription.indostarbes14,
            'diff': ['Panjang']
          }, {
            'name': 'Gelombang 11',
            'description': ItemDescription.indostarbes11,
            'diff': ['Panjang']
          }
        ]
      },{
        'name': 'Indostar Plank',
        'img': 'assets/Indostar Plank.png',
        'icon': 'assets/Logo Indostar Plank.png',
        'type': [
          {
            'name': 'Plank',
            'description': ItemDescription.plank,
            'diff': ['Panjang', 'Lebar']
          }, {
            'name': 'Plank Texture',
            'description': ItemDescription.plankTexture,
            'diff': ['Panjang', 'Lebar']
          }
        ]
      }, 
    ],
    'img': 'assets/Logo Indostar.png',
    'bg': 'assets/background-1a.jpg',
    'color': Colors.blueGrey
  },
  {
    'name': 'ECO',
    'subitem': [ 
      {
        'name': 'ECO Board',
        'img': 'assets/Indostar Board.png',
        'icon': 'assets/Logo Merk ECO Board.png',
        'type': [
          {
            'name': 'Board Imperial',
            'description': ItemDescription.imperial,
            'diff': ['Tebal']
          }, {
            'name': 'Board Matric',
            'description': ItemDescription.matric,
            'diff': ['Tebal']
          }, {
            'name': 'Board Square',
            'description': ItemDescription.square,
            'diff': ['Panjang']
          }
        ]
      }, {
        'name': 'ECObes',
        'img': 'assets/Indostar Bes.png',
        'icon': 'assets/Logo ECObes.png',
        'type': [
          {
            'name': 'Gelombang 14',
            'description': ItemDescription.indostarbes14,
            'diff': ['Panjang']
          }, {
            'name': 'Gelombang 11',
            'description': ItemDescription.indostarbes11,
            'diff': ['Panjang']
          }
        ]
      }
    ],
    'img': 'assets/Logo Merk ECO.png',
    'bg': 'assets/background-3a.png',
    'color': Colors.lightGreen
  }];
}
