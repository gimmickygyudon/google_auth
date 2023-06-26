import 'package:flutter/material.dart';

class Date {
  static DateTime now = DateTime.now();

  static Future<DateTime?> showDate(BuildContext context, DateTime? date) async {

    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      confirmText: 'Selesai',
      cancelText: 'Batal'
    );

    return result;
  }

  static Future<DateTimeRange?> showDateRange(BuildContext context, DateTime? date) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      locale: const Locale('id', 'ID'),
      firstDate: date ?? DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Selesai',
    );

    return result;
  }

  static Future<TimeOfDay?> showTime(BuildContext context, TimeOfDay? time) async {

    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: time ?? TimeOfDay.now(),
      hourLabelText: 'Jam',
      minuteLabelText: 'Menit',
      confirmText: 'Selesai',
      cancelText: 'Batal'
    );

    return result;
  }

}