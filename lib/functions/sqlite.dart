// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'sql_client.dart';

class SQLite {
  static Future<Database> initializeDatabaseLocal() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mis.db');

    //// DEMO MODE
    // await deleteDatabase(path);
    Database database;

    // Check if the database exists
    await databaseExists(path).then((value) async {});

    database = await openDatabase(
      join(await getDatabasesPath(), 'mis.db'),
      singleInstance: true,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE USR2(id_usr2 INTEGER PRIMARY KEY AUTOINCREMENT, id_ousr INTERGER, remarks TEXT, id_ocst TEXT, sync INTEGER DEFAULT 0)'
        );
        db.execute(
          'CREATE TABLE payment(id_opor INTEGER PRIMARY KEY AUTOINCREMENT, customer_reference_number TEXT, id_ousr TEXT, id_usr1 TEXT, delivery_date TEXT, delivery_type TEXT, document_remarks TEXT, payment_type TEXT,'
          'delivery_name TEXT, delivery_street TEXT, province TEXT, district TEXT, subdistrict TEXT, suburb TEXT, phone_number TEXT,'
          'POR1s TEXT, isSent INTEGER)'
        );
      },
      version: 1,
    );

    return database;
  }

  static Future<Map> insert({required String table, required Map<String, dynamic> item}) async {
    await initializeDatabaseLocal().then((db) {
      db.insert(table, item).then((value) => debugPrint('Insert Local Succeed: $value'));
    });

    return item;
  }

  static Future<List<Map>?> retrieve({required String table, required List queries, required String where}) async {
    return await initializeDatabaseLocal().then((db) async {
      try {
        List<Map> data = await db.query(table, where: '$where = ? and sync = 0', whereArgs: queries)
        .onError((error, stackTrace) async => List.empty());
        return data;
      } catch (e) {
        return null;
      }
    });
  }
}


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
    await databaseExists(path).then((value) async => debugPrint('Local Database Exists: $value'));

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
        return Future.error(error.toString());
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
  final String id_oitm;
  final String name;
  final String brand;
  final String dimension;
  final List<String> dimensions;
  final String weight;
  final List<String> weights;
  final String count;

  const Cart({
    required this.id_oitm,
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
      'id_oitm': id_oitm,
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
      Cart.set(cartItems);
    } else {
      Cart.set([source]);
    }
  }

  static Future<void> counts({required int index, required String count}) async {
    await Cart.getItems().then((value) {
      List? elements = value;

      elements?[index]['count'] = count;

      if (elements != null) Cart.set(elements);
    });
  }

  static Future<void> update({required int index, required List<String> element, required int selectedIndex}) async {
    await Cart.getItems().then((value) {
      List? elements = value;

      for (String e in element) {
        elements?[index][e] = elements[index]['${e}s'][selectedIndex];
      }

      if (elements != null) Cart.set(elements);
    });
  }

  static Future<void> remove({required List<int> index}) async {
    await Cart.getItems().then((value) {
      List? elements = value;

      for (int i in index) {
        elements?[i] = null;
      }

      if (elements != null) {
        elements.removeWhere((element) => element == null);
        Cart.set(elements);
      } else {
        CartWidget.cartNotifier.value = List.empty(growable: true);
      }
    });
  }

  static Future<void> set(List source) async {
    final prefs = await SharedPreferences.getInstance();

    CartWidget.cartNotifier.value = source;
    prefs.setString('Cart', jsonEncode(source)).whenComplete(() => getItems());
  }

  static Future<void> removeAll() async {
    final prefs = await SharedPreferences.getInstance();

    CartWidget.cartNotifier.value = List.empty(growable: true);
    prefs.remove('Cart');
  }

  static Future<List?> getItems() async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonData = prefs.getString('Cart');
    List? items;

    if (jsonData != null) {
      items = jsonDecode(jsonData);
      CartWidget.cartNotifier.value = items!;

      return items;
    } else {
      CartWidget.cartNotifier.value = List.empty(growable: true);

      return items;
    }
  }
}

class Item {
  final String id_oitm;
  final String item_description;
  final String spesification;
  final String weight;

  Item({
    required this.id_oitm,
    required this.item_description,
    required this.spesification,
    required this.weight
  });

  Map<String, dynamic> toMap() {
    return {
      'id_oitm': id_oitm,
      'item_description': item_description,
      'spesification': spesification,
      'weight': weight,
    };
  }

  // TODO: Cachce Brands Item -> Get the Names From Database
  static Map<String, AsyncMemoizer<List?>> listItemsMemoizer =
  {
    'Indostar': AsyncMemoizer<List?>(),
    'ECO': AsyncMemoizer<List?>()
  };

  static Future<List?> getItems({required String brand}) {
    return listItemsMemoizer[brand]!.runOnce(() {
      FutureOr<List?> list = fetchItems(brand: brand);
      return list;
    })
    .onError((error, stackTrace) {
      return fetchItems(brand: brand);
    })
    .then((value) {
      if (value == null) {
        return fetchItems(brand: brand);
      }

      return value;
    });
  }

  static Map<String, AsyncMemoizer<Map>> itemMemoizer = {};
  static Future<Map> getItem({required String id_oitm}) {
    if (itemMemoizer.containsKey(id_oitm)) {
      return itemMemoizer[id_oitm]!.runOnce(() {
        return SQL.retrieve(api: 'sim/oitm', query: 'id_oitm=$id_oitm').then((value) {
          return value;
        });
      });
    } else {
      itemMemoizer.addAll({id_oitm: AsyncMemoizer<Map>()});
      return itemMemoizer[id_oitm]!.runOnce(() {
        return SQL.retrieve(api: 'sim/oitm', query: 'id_oitm=$id_oitm').then((value) {
          return value;
        });
      });
    }
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

  static String defineName(String value) {
    return value.replaceAll(RegExp(r'[0-9]'), '').toTitleCase().replaceAll(' X', '').replaceAll(' .', '');
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
}
