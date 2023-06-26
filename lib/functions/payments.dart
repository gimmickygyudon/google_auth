// ignore_for_file: non_constant_identifier_names

import 'package:google_auth/functions/sql_client.dart';

class Payment {
  final int? id_opor;
  final String purchase_order_code, customer_reference_number, id_ousr, id_usr1;
  final String delivery_date, delivery_type, document_remarks, payment_type;

  const Payment({
    required this.id_opor,
    required this.purchase_order_code,
    required this.customer_reference_number,
    required this.id_ousr,
    required this.id_usr1,
    required this.delivery_date,
    required this.delivery_type,
    required this.document_remarks,
    required this.payment_type
  });

  Map<String, dynamic> toMap() {
    return {
      'id_opor': id_opor,
      'purchase_order_code': purchase_order_code,
      'customer_reference_number': customer_reference_number,
      'id_ousr': id_ousr,
      'id_usr1': id_usr1,
      'delivery_date': delivery_date,
      'delivery_type': delivery_type,
      'document_remarks': document_remarks,
      'payment_type': payment_type,
    };
  }

  static Future<List<String>> getPaymentType() {
    return SQL.retrieveAll(api: 'opty').then((value) {
      List<String> list = value.map<String>((element) { return element['description']; }).toList();

      return list;
    });
  }

  static Future<List> getPaymentHistory() {
    return SQL.retrieveAll(api: 'po').then((value) {
      print(value);
      return value;
    });
  }

}