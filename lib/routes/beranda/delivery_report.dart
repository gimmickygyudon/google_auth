// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/widgets/handle.dart';

import '../../functions/customer.dart';
import '../../widgets/chart.dart';

class ReportDeliveryWidget extends StatefulWidget {
  const ReportDeliveryWidget({super.key});

  @override
  State<ReportDeliveryWidget> createState() => _ReportDeliveryWidgetState();
}

class _ReportDeliveryWidgetState extends State<ReportDeliveryWidget> {
  late List<String> datesRange;
  late String dateRange;
  late Future<DeliveryOrder> _reportDelivery;

  List<double> total = List.generate(3, (index) => 0.0);

  @override
  void initState() {
    datesRange = ['Minggu Ini', 'Bulan Ini', '3 Bulan', '6 Bulan', 'Total'];
    dateRange = datesRange[1];

    setReportDelivery();
    super.initState();
  }

  void setReportDelivery() {
    // TODO: id_ocst PINNED or SET AS DEFAULT
    String id_ocst = 'CUS01621';

    _reportDelivery = DeliveryOrder.retrieveMonth(id_osct: id_ocst, date: DateTime(DateTime.now().year, 05)).then((value) {
      List<double> tonase = List.empty(growable: true);
      for (Map element in value) {
        tonase.add(double.parse(element['tonage'] ?? 0.0));
      }

      total[0] = DeliveryOrder.defineTonage(tonage: tonase);
      total[1] = 1000.4;
      total[2] = 600.0;
      return DeliveryOrder(
        tonage: total[0],
        outstanding_tonage: total[1],
        target: total[2]
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Card(
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
        elevation: 0,
        child: FutureBuilder(
          future: _reportDelivery,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: HandleLoading());
            } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Perolehan Kamu', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 0
                          )),
                          const SizedBox(width: 10),
                          Icon(Icons.more_horiz, size: 20, color: Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: dateRange,
                          onChanged: (value) => setState(() => dateRange = value.toString()),
                          padding: const EdgeInsets.only(left: 6),
                          isDense: true,
                          borderRadius: BorderRadius.circular(8),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 0),
                          items: datesRange.map((date) {
                            return DropdownMenuItem(
                              value: date,
                              child: Text(date)
                            );
                          }).toList()
                        ),
                      )
                    ],
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: POChartWidget(
                                    DeliveryOrder(
                                      tonage: snapshot.data!.tonage,
                                      outstanding_tonage: snapshot.data!.outstanding_tonage,
                                      target: snapshot.data!.target
                                    )
                                  )
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    children: [
                                      Chip(
                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                        padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        backgroundColor: DeliveryOrder.description(context: context)[0]['color'],
                                        label: const Text('10 %'),
                                        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.surface
                                        ),
                                      ),
                                      Chip(
                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                        padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        backgroundColor: DeliveryOrder.description(context: context)[1]['color'],
                                        label: const Text('10 %'),
                                        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.surface
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            for (var i = 0; i < total.length; i++)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 14,
                                            width: 14,
                                            decoration: BoxDecoration(
                                              color: DeliveryOrder.description(context: context)[i]['color'],
                                              borderRadius: BorderRadius.circular(4)
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(DeliveryOrder.description(context: context)[i]['name'], style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            letterSpacing: 0
                                          )),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text('${total[i]} Ton', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        letterSpacing: 0
                                      )),
                                    ),
                                    Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.secondary)
                                  ],
                                ),
                                Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), height: 0.5, thickness: 0.5)
                              ],
                            )
                          ]
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: ButtonStyle(
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 6)),
                        textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.25)),
                        iconSize: const MaterialStatePropertyAll(16)
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rincian Pencapaian'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
            } else {
              return const HandleNoInternet(message: 'Tidak Terkoneksi ke Internet');
            }
          }
        ),
      ),
    );
  }
}