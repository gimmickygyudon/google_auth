// ignore_for_file: non_constant_identifier_names
import 'package:intl/intl.dart';
String DateNow() => DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime.now());
String DateNowSQL() => DateFormat('y-MM-d H:m:ss').format(DateTime.now());
String TimeNow() => DateFormat('HH:mm').format(DateTime.now());

List<String> generateListofMonths(DateTime time) {
  List<String> months = List.empty(growable: true);
  for (int i = 1; i < 13; i++) {
    months.add(DateFormat('MMMM').format(DateTime(time.year, i, time.day)));
  }

  return months;
}

List<String> generateListoYears(DateTime time) {
  List<String> years = List.empty(growable: true);

  for (int i = time.year; i > time.year - 5; i--) {
    years.add(DateFormat('yyyy').format(DateTime(i)));
  }

  return years.reversed.toList();
}

Map<String, String> getCurrentStartEndWeek(DateTime date, {String format = 'yyyy-MM-dd'}) {
  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  final from_date = getDate(date.subtract(Duration(days: date.weekday - 1)));
  final to_date = getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)));

  final String from_dateSet = DateFormat(format, 'id').format(from_date);
  final String to_dateSet = DateFormat(format, 'id').format(to_date);

  return { from_dateSet: to_dateSet };
}


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
