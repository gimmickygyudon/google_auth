import 'package:flutter/material.dart';

class Date {
  static DateTime now = DateTime.now();

  static Future<DateTime?> showDate(BuildContext context) async {

    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, now.day),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      confirmText: 'Selesai',
      cancelText: 'Batal'
    );

    return result;
  }

  static Future<DateTimeRange?> showDateRange(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      locale: const Locale('id', 'ID'),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Selesai',
    );

    return result;
  }

  static Future<TimeOfDay?> showTime(BuildContext context) async {

    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      hourLabelText: 'Jam',
      minuteLabelText: 'Menit',
      confirmText: 'Selesai',
      cancelText: 'Batal'
    );

    return result;
  }

}