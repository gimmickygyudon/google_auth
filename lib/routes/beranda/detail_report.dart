import 'package:flutter/material.dart';
import 'package:google_auth/routes/beranda/delivery_report.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/profile.dart';

class DetailReportRoute extends StatefulWidget {
  const DetailReportRoute({super.key});

  @override
  State<DetailReportRoute> createState() => _DetailReportRouteState();
}

class _DetailReportRouteState extends State<DetailReportRoute> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context)
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight + 10,
          title: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: CustomerSelectWidget(onChanged: () {}),
          ),
          actions: [
            ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
            const SizedBox(width: 12)
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analisa Pencapaian', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                letterSpacing: 0
              )),
              Text('Rincian detail delivery order anda selama ini.', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0
              )),
              const SizedBox(height: 40),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ringkasan', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Expanded(child: const SingleChoice())
                ],
              )
            ],
          ),
       )
      ),
    );
  }
}

enum Calendar { day, week, month, year }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          )
        ),
        side: const MaterialStatePropertyAll(BorderSide.none),
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 2)),
        textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall)
      ),
      showSelectedIcon: false,
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
            value: Calendar.day,
            label: Text('Day'),
          ),
        ButtonSegment<Calendar>(
            value: Calendar.week,
            label: Text('Week'),
          ),
        ButtonSegment<Calendar>(
            value: Calendar.month,
            label: Text('Month'),
          ),
        ButtonSegment<Calendar>(
            value: Calendar.year,
            label: Text('Year'),
          ),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          calendarView = newSelection.first;
        });
      },
    );
  }
}