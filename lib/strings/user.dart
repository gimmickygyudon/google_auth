// ignore_for_file: non_constant_identifier_names
import 'package:intl/intl.dart';
String DateNow() => DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime.now());
String DateNowSQL() => DateFormat('y-MM-d H:m:ss').format(DateTime.now());
String TimeNow() => DateFormat('HH:mm').format(DateTime.now());

Map<String, dynamic> currentUserFormat(
  {
    required int? id_ousr,
    required String login_type,
    required String user_email,
    required String user_name,
    required String phone_number,
    required String user_password
  }) {

  Map<String, dynamic> user = {
    'id_ousr': id_ousr,
    'login_type': login_type,
    'user_email': user_email,
    'user_name': user_name,
    'phone_number': phone_number,
    'user_password': user_password
  };
  return user;
}

Map<String, dynamic> currentUser = {};
