// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/sql_client.dart';
import 'package:intl/intl.dart';

class Customer {
  final int? id_usr2;
  final String id_ousr;
  final String remarks;
  final String? id_ocst;

  const Customer({
    required this.id_usr2,
    required this.id_ousr,
    required this.remarks,
    required this.id_ocst
  });

  Map<String, dynamic> toMap() {
    return {
      'id_usr2': id_usr2,
      'id_ousr': id_ousr,
      'remarks': remarks,
      'id_osct': id_ocst,
    };
  }

  static Future<Map> insert(Customer customer) {
    return SQL.insert(item: customer.toMap(), api: 'usr2');
  }

  static Future<List<Customer>> retrieve({required id_ousr}) {
    return SQL.retrieve(api: 'usr2', query: 'id_ousr=$id_ousr').then((value) {
      List<Customer> customers = List.empty(growable: true);

      if (value is Map) {
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
            id_ousr: customer['id_ousr'],
            remarks: customer['remarks'],
            id_ocst: customer['id_osct']
          ));
        }
      }

      return customers;
    });
  }

  static Future<void> remove({required String id_usr2}) async {
    await SQL.delete(api: 'usr2', query: 'id_usr2=$id_usr2').then((value) {
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

  static Future<List> retrieveMonth({required String id_osct, required DateTime date}) async {
    String month = DateFormat('y-MM').format(date);

    return await SQL.retrieve(api: 'sim2/do', query: 'id_ocst=$id_osct&surat_jalan_date=$month');
  }

  static double defineTonage({required List<double> tonage}) {
    double sum = tonage.fold(0, (previousValue, element) => previousValue + element);
    String calculate = (sum / 1000).toStringAsFixed(2);

    return double.parse(calculate);
  }
}