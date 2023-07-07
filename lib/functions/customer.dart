// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/sql_client.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/strings/user.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customer extends Equatable {
  final int? id_usr2;
  final String id_ousr;
  final String remarks;
  final String? id_ocst;
  final int? sync;

  const Customer({
    this.id_usr2,
    required this.id_ousr,
    required this.remarks,
    required this.id_ocst,
    this.sync = 0
  });

  @override
  List<Object?> get props => [id_usr2, id_ousr, remarks, id_ocst, sync];

  Map<String, dynamic> toMap() {
    return {
      'id_usr2': id_usr2,
      'id_ousr': id_ousr,
      'remarks': remarks,
      'id_ocst': id_ocst,
      'sync': sync
    };
  }

  static ValueNotifier<Customer?> defaultCustomer = ValueNotifier(null);

  static void setDefaultCustomer(Customer? customer) async {
    final prefs = await SharedPreferences.getInstance();

    defaultCustomer.value = customer;
    prefs.setString('Customer', jsonEncode(customer?.toMap()));
  }

  static Future<Customer?> getDefaultCustomer() async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonData = prefs.getString('Customer');
    if (jsonData != null) {
      Map jsondata = jsonDecode(jsonData);

      // HACK: Validate Data Local and DB
      final Customer? data = await Customer.retrieve(id_ousr: currentUser['id_ousr']).then((customers) {
        if (customers.isEmpty) return null;
        return customers.singleWhere((customer) => customer.id_usr2 == jsondata['id_usr2']);
      });

      if (data != null) {
        Customer customer = Customer(
          id_usr2: data.id_usr2,
          id_ousr: data.id_ousr,
          remarks: data.remarks,
          id_ocst: data.id_ocst
        );

        defaultCustomer.value = customer;
        return customer;
      } else {
        return null;
      }

    } else {
      return Customer.retrieve(id_ousr: currentUser['id_ousr']).then((customer) {
        defaultCustomer.value = customer.first;
        return customer.first;
      });
    }
  }

  static ValueNotifier<List<Customer?>?> listCustomer = ValueNotifier(null);

  static Future<Map> insert(Customer customer) {
    return SQL.insert(item: customer.toMap(), api: 'usr2')
    .onError((error, stackTrace) {
      // SQL Local
      return SQLite.insert(table: 'usr2', item: customer.toMap());
    })
    .then((value) {
      if (defaultCustomer.value == null) {
        defaultCustomer.value = Customer(
          id_usr2: value['id_usr2'],
          id_ousr: value['id_ousr'],
          remarks: value['remarks'],
          id_ocst: value['id_ocst']
        );
        setDefaultCustomer(defaultCustomer.value);
      }
      return value;
    });
  }

  static Future<List<Customer>> retrieve({required int id_ousr}) {
    return SQL.retrieve(api: 'usr2', query: 'id_ousr=$id_ousr')
    .onError((error, stackTrace) {
      // SQL Local
      return SQLite.retrieve(table: 'usr2', queries: [id_ousr], where: 'id_ousr');
    })
    .then((value) {
      List<Customer> customers = List.empty(growable: true);

      if (value is Map) {
        customers = List.empty(growable: true);
        customers.add(Customer(
          id_usr2: value['id_usr2'],
          id_ousr: value['id_ousr'],
          remarks: value['remarks'],
          id_ocst: value['id_ocst']
        ));
      } else {
        for (Map customer in value) {
          customers.add(Customer(
            id_usr2: customer['id_usr2'],
            id_ousr: customer['id_ousr'].toString(),
            remarks: customer['remarks'],
            id_ocst: customer['id_ocst']
          ));
        }
      }

      return customers;
    });
  }

  static Future<void> remove({required String id_usr2}) async {
    await SQL.delete(api: 'usr2', query: 'id_usr2=$id_usr2').then((value) {
      // Set default customer when its empty
      Customer.retrieve(id_ousr: currentUser['id_ousr']).then((value) async {
        for (int i = 0; i < value.length; i++) {
          if (value[i] != await getDefaultCustomer()) {
            if (value.isEmpty) {
              setDefaultCustomer(null);
            } else {
              setDefaultCustomer(value[0]);
            }
          }
        }
      });
    });
  }
}

class DeliveryOrder {
  final int? id_ocst;
  final double tonage, outstanding_tonage, target;

  const DeliveryOrder({
    this.id_ocst,
    required this.tonage,
    required this.outstanding_tonage,
    required this.target,
  });

  static List<Map> description({required BuildContext context}) => [
    {
      'name': 'Realisasi',
      'color': Theme.of(context).colorScheme.primary
    }, {
      'name': 'Outstanding',
      'color': Theme.of(context).colorScheme.inversePrimary
    }, {
      'name': 'Target',
      'color': Theme.of(context).colorScheme.outlineVariant
    }
  ];

  // 3 BULAN
  static Future<Map> retrieveLastMonths({required String id_ocst, required DateTime from, required DateTime to}) async {
    String from_month = DateFormat('y-MM-dd').format(from);
    String to_month = DateFormat('y-MM-dd').format(to);

    return await SQL.retrieve(api: 'sim2/do', query: 'id_ocst=$id_ocst&from_date=$from_month&to_date=$to_month');
  }

  // BULAN INI
  static Future<Map> retrieveMonth({required String id_ocst, required DateTime date}) async {
    String month = DateFormat('y-MM').format(date);

    return await SQL.retrieve(api: 'sim2/do', query: 'id_ocst=$id_ocst&surat_jalan_date=$month');
  }

  // MINGGU INI
  static Future<Map> retrieveWeek({required String id_ocst, required DateTime date}) async {
    String from_date = getCurrentStartEndWeek(date).keys.first;
    String to_date = getCurrentStartEndWeek(date).values.first;

    return await SQL.retrieve(api: 'sim2/do', query: 'id_ocst=$id_ocst&from_date=$from_date&to_date=$to_date');
  }

  static double defineTonage({required List<double> tonage}) {
    double sum = tonage.fold(0, (previousValue, element) => previousValue + element);
    String calculate = (sum / 1000).toStringAsFixed(2);

    return double.parse(calculate);
  }
}
