// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:google_auth/functions/sql_client.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Payment {
  final int? id_opor;
  final String customer_reference_number, id_ousr;
  final String delivery_date, document_remarks, payment_type;
  final String? delivery_type;

  final String delivery_name, delivery_street, province, district, subdistrict, suburb, phone_number;
  final int isSent;

  final String POR1s;

  const Payment({
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

  static Future<Database> initializeDatabaseLocal() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mis.db');
    //// DEMO
    // await deleteDatabase(path);
    Database database;

    // Check if the database exists
    await databaseExists(path).then((value) async => print(value));

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

  static Future<List> getPaymentHistoryLocal() async {
    final db = await initializeDatabaseLocal();

    List list = await db.query('payment').then((value) {
      return value.map((e) {
        Map element = Map.from(e);
        element['POR1s'] = jsonDecode(element['POR1s'] as String);
        return element;
      }).toList();
    });

    print(list);
    return list;
  }

  static Future<List<String>> getPaymentType() {
    return SQL.retrieveAll(api: 'opty').then((value) {
      List<String> list = value.map<String>((element) { return element['description']; }).toList();

      return list;
    });
  }

  static Future<List> getPaymentHistory() {
    return SQL.retrieveAll(api: 'po').then((value) {
      return value;
    });
  }

}