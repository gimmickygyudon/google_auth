// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_auth/functions/location.dart';
import 'package:google_auth/functions/sql_client.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../strings/user.dart';

class Payment {
  final int? id_usr1, id_opor;
  final String customer_reference_number, id_ousr;
  final String delivery_date, document_remarks, payment_type;
  final String? delivery_type;

  final String delivery_name, delivery_street, province, district, subdistrict, suburb, phone_number;
  final int isSent;

  final dynamic POR1s;

  const Payment({
    this.id_usr1,
    required this.id_opor,
    required this.customer_reference_number,
    required this.id_ousr,
    required this.delivery_date,
    required this.delivery_type,
    required this.document_remarks,
    required this.payment_type,

    required this.delivery_name,
    required this.delivery_street,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.suburb,
    required this.phone_number,

    required this.POR1s,

    required this.isSent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_usr1': id_usr1,
      'id_opor': id_opor,
      'customer_reference_number': customer_reference_number,
      'id_ousr': id_ousr,
      'delivery_date': delivery_date,
      'delivery_type': delivery_type,
      'document_remarks': document_remarks,
      'payment_type': payment_type,

      'delivery_name': delivery_name,
      'delivery_street': delivery_street,
      'province': province,
      'district': district,
      'subdistrict': subdistrict,
      'suburb': suburb,
      'phone_number': phone_number,

      'POR1s': POR1s,

      'isSent': isSent,
    };
  }

  static List<Map> payments = [
    {
      'name': 'COD',
      'icon': Icons.local_atm
    }, {
      'name': 'CASH',
      'icon': Icons.money
    }, {
      'name': 'BANK',
      'icon': Icons.payment
    }
  ];

  static Future<Database> initializeDatabaseLocal() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mis.db');
    //// DEMO
    // await deleteDatabase(path);
    Database database;

    // Check if the database exists
    await databaseExists(path).then((value) async => debugPrint('Local Database: $value'));

    database = await openDatabase(
      join(await getDatabasesPath(), 'mis.db'),
      singleInstance: true,
      onCreate: (db, version) {
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

  static Future<Payment> insertPaymentLocal(Payment payment) async {
    final db = await initializeDatabaseLocal();

    await db.insert(
      'payment',
      payment.toMap(),
    );

    return payment;
  }

  static Future<Map> insertPayment(Payment payment) {
    return SQL.insert(api: 'po', item: {
      'id_usr1': null,
      'id_ousr': currentUser['id_ousr'],
      'delivery_name': payment.delivery_name,
      'delivery_street': payment.delivery_street,
      'id_oprv': payment.province,
      'id_octy': payment.district,
      'id_osdt': payment.subdistrict,
      'id_ovil': payment.suburb,
      'phone_number': payment.phone_number,

      'id_opor': null,
      'customer_reference_number': payment.customer_reference_number,
      'delivery_date': payment.delivery_date,
      'delivery_type': payment.delivery_type,
      'document_remarks': payment.document_remarks,
      'payment_type': payment.payment_type,

      'por1': payment.POR1s
    })
    .onError((error, stackTrace) => Future.error('test #1'))
    .then((value) => value);
  }

  static Future<List> getPaymentHistoryLocal({required String id_ousr}) async {
    final db = await initializeDatabaseLocal();

    List list = await db.rawQuery('SELECT * FROM payment WHERE id_ousr = $id_ousr').then((value) {
      return value.map((e) {
        Map element = Map.from(e);
        element['POR1s'] = jsonDecode(element['POR1s'] as String);
        return element;
      }).toList();
    });

    return list;
  }

  static Future<void> deletePaymentHistoryLocal({required int id}) async {
    final db = await initializeDatabaseLocal();

    await db.delete('payment', where: 'id_opor = ?', whereArgs: [id]).whenComplete(() => debugPrint('Local Database Deleted!'));
  }

  static Future<List> syncPaymentHistory({required String id_ousr}) {
    return getPaymentHistoryLocal(id_ousr: id_ousr).then((value) async {
      if (value.isNotEmpty) {
        // Get locations id
        List<int> locationIds = await LocationManager.getLocationsId().then((locationIds) async {
          return locationIds;
        }).onError((error, stackTrace) {
          return Future.error(error.toString());
        });

        return await Future.wait([
          for (var element in value)
            if (element['isSent'] == 0)
              insertPayment(Payment(
              id_opor: null,
              customer_reference_number: element['customer_reference_number'],
              id_ousr: element['id_ousr'],
              delivery_date: element['delivery_date'],
              delivery_type: element['delivery_type'],
              document_remarks: element['document_remarks'],
              payment_type: element['payment_type'],
              delivery_name: element['delivery_name'],
              delivery_street: element['delivery_street'],
              province: locationIds[0].toString(),
              district: locationIds[1].toString(),
              subdistrict: locationIds[2].toString(),
              suburb: locationIds[3].toString(),
              phone_number: element['phone_number'],
              POR1s: element['POR1s'],
              isSent: 1
            ))
            .onError((error, stackTrace) => Future.error('test #2'))
            .then((_) {
              deletePaymentHistoryLocal(id: element['id_opor']);
            })
        ]);
      } else {
        return List.empty();
      }
    });
  }

  static Future<List<String>> getPaymentType() {
    return SQL.retrieveAll(api: 'opty').then((value) {
      List<String> list = value.map<String>((element) { return element['description']; }).toList();

      return list;
    });
  }

  static Future<List> getPaymentHistory({required String id_ousr}) {
    return SQL.retrieve(api: 'po', query: 'id_ousr=$id_ousr')
    .onError((error, stackTrace) => Future.error(error.toString()))
    .then((value) {
      if (value is List) {
        return value;
      } else {
        List list = List.empty(growable: true);
        list.add(value);

        return list;
      }
    });
  }

}