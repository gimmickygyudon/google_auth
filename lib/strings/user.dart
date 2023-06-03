// ignore_for_file: non_constant_identifier_names
import 'package:intl/intl.dart';

String DateNow = DateFormat('kk:mm y/M/d').format(DateTime.now());
String DateNowSQL = DateFormat('y-MM-d H:m:ss').format(DateTime.now());
Map<String, dynamic> currentUser = {};

class UserSqlFormat {
  static Map<String, dynamic> olog(
    {
      required String? id_olog, 
      required String date_time, 
      required String form_sender, 
      required String remarks, 
      required String source,
    }) {
    return {
      'id_olog': id_olog,
      'date_time': date_time,
      'form_sender': form_sender,
      'remarks': remarks,
      'source': source,
    };
  }
}