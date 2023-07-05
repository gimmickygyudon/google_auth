// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/widgets/chip.dart';
import 'package:google_auth/widgets/handle.dart';

import '../../functions/customer.dart';
import '../../widgets/chart.dart';

class ReportDeliveryWidget extends StatefulWidget {
  const ReportDeliveryWidget({super.key});

  @override
  State<ReportDeliveryWidget> createState() => _ReportDeliveryWidgetState();
}

class _ReportDeliveryWidgetState extends State<ReportDeliveryWidget> {
  bool isOffline = false;

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
    })
    .onError((error, stackTrace) {
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() => isOffline = true);
      });
      return const DeliveryOrder(tonage: 99.9, outstanding_tonage: 99.9, target: 99.9);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: FutureBuilder(
        future: _reportDelivery,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: snapshot.connectionState == ConnectionState.waiting 
            ? SizedBox(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const HandleLoadingBar()
              ),
            )
            : Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
                    Theme.of(context).colorScheme.primaryContainer
                  ]
                )
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  border: isOffline ? Border(top: BorderSide(width: 2, color: Theme.of(context).colorScheme.error)) : Border.all(width: 0, color: Colors.transparent)
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                              if (isOffline) const ChipOffline()
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
                                          ChipSmall(
                                            bgColor: DeliveryOrder.description(context: context)[0]['color'], 
                                            label: '10 %', 
                                            labelColor: Theme.of(context).colorScheme.surface
                                          ),
                                          ChipSmall(
                                            bgColor: DeliveryOrder.description(context: context)[1]['color'], 
                                            label: '10 %', 
                                            labelColor: Theme.of(context).colorScheme.inverseSurface
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
                                  ],
                                )
                              ]
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      MediaQuery.removePadding(
                        context: context,
                        removeLeft: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ActionChip(
                              onPressed: () {},
                              avatar: const Icon(Icons.account_circle),
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.7)),
                              side: BorderSide.none,
                              labelPadding: const EdgeInsets.only(right: 4),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Pion'),
                                  Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary)
                                ],
                              ),
                              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary
                              ),
                            ),
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
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
