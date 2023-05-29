// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserLog {
  final int? id_olog;
  final String date_time;
  final String form_sender, remarks, source;

  const UserLog({
    required this.id_olog,
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
    print(databasesPath);
    String path = join(databasesPath, 'olog.db');
    Database database;

    // Check if the database exists
    bool exists = await databaseExists(path);

    if (exists) print('file exists');
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
            source: item['source']);
      }).toList();
    } else {
      return List.generate(maps.length, (i) {
        return UserLog(
            id_olog: maps[i]['id_olog'],
            date_time: maps[i]['date_time'],
            form_sender: maps[i]['form_sender'],
            remarks: maps[i]['remarks'],
            source: maps[i]['source']);
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

  static void log_user(String email, Map<String, dynamic> currentUser) {
    UserLog.retrieve(currentUser['email']).then((value) {
      String? data = value.where((element) => element.source == currentUser['email']).toString().replaceAll('(', '').replaceAll(')', '');
      // check if email already exist.
      if (data.isEmpty) {
        UserLog newUser = UserLog(
          id_olog: null,
          date_time: currentUser['date'],
          form_sender: currentUser['loginWith'],
          remarks: currentUser['name'],
          source: currentUser['email']);
        UserLog.insert(newUser);
        print('input success');
      }
    });
  }
}
