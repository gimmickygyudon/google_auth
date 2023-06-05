// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import 'sql_client.dart';

class UserLog {
  final int? id_olog;
  final String date_time;
  final String form_sender, remarks, source;

  const UserLog({
    this.id_olog,
    required this.date_time,
    required this.form_sender,
    required this.remarks,
    required this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_olog': id_olog,
      'date_time': date_time,
      'form_sender': form_sender,
      'remarks': remarks,
      'source': source,
    };
  }

  @override
  String toString() {
    return '{id_olog: $id_olog, date_time: $date_time, form_sender: $form_sender, remarks: $remarks, source: $source}';
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
    final db = await UserLog.initializeDatabase();
    await db.insert(
      'olog',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    UserRegister.retrieve(user.source).then((value) {
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
          source: item['source']
        );
      }).toList();
    } else {
      return List.generate(maps.length, (i) {
        return UserLog(
          id_olog: maps[i]['id_olog'],
          date_time: maps[i]['date_time'],
          form_sender: maps[i]['form_sender'],
          remarks: maps[i]['remarks'],
          source: maps[i]['source']
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
    var databasesPath = await getDatabasesPath();
    // print('sqlite(initializeDatabase): $databasesPath');
    String path = join(databasesPath, 'ousr.db');
    Database database;

    // Check if the database exists
    await databaseExists(path).then((value) => print('sqlite(initializeDatabase): file exists'));

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
      print('isEmail: $item');

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
