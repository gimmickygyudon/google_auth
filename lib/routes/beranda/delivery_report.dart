// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/chip.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:intl/intl.dart';

import '../../functions/customer.dart';
import '../../widgets/chart.dart';
import '../../widgets/dropdown.dart';

class ReportDeliveryWidget extends StatefulWidget {
  const ReportDeliveryWidget({super.key});

  @override
  State<ReportDeliveryWidget> createState() => _ReportDeliveryWidgetState();
}

class _ReportDeliveryWidgetState extends State<ReportDeliveryWidget> {
  bool isOffline = false;

  late List<String> datesRange;
  late String dateRange;
  late String date;
  late Future<DeliveryOrder> _reportDelivery;

  List<double> total = List.generate(3, (index) => 0.0);
  List<String> percent = List.generate(2, (index) => '0.0');

  @override
  void initState() {
    datesRange = ['Minggu Ini', 'Bulan Ini', '3 Bulan', '6 Bulan', 'Total'];
    dateRange = datesRange[1];

    _reportDelivery = setReportDelivery();
    _defaultCustomerListener();
    super.initState();
  }

  @override
  void dispose() {
    Customer.defaultCustomer.removeListener(() { });
    super.dispose();
  }

  _defaultCustomerListener() {
    Customer.defaultCustomer.addListener(() {
      if (mounted) setReportDelivery();
    });
  }

  Future<DeliveryOrder> setReportDelivery() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);

    if (id_ocst != null) {
      Future<Map> deliveryOrder;

      switch (dateRange.toUpperCase()) {
        case 'MINGGU INI':
          date = '${getCurrentStartEndWeek(DateTime.now(), format: 'dd MMMM').keys.first}  -  ${getCurrentStartEndWeek(DateTime.now(), format: 'dd MMMM').values.first}';
          deliveryOrder = DeliveryOrder.retrieveWeek(id_ocst: id_ocst, date: DateTime.now());
        break;

        case 'BULAN INI':
          LastDateFrom lastDate = LastDateFrom.months(interval: 0);

          date = DateFormat('MMMM ''yyyy', 'id').format(lastDate.to);
          deliveryOrder = DeliveryOrder.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        case '3 BULAN':
          LastDateFrom lastDate = LastDateFrom.months(interval: 3);

          date = '${DateFormat('MMMM ''yyyy', 'id').format(lastDate.from)}  -  ${DateFormat('MMMM ''yyyy', 'id').format(lastDate.to)}';
          deliveryOrder = DeliveryOrder.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        case '6 BULAN':
          LastDateFrom lastDate = LastDateFrom.months(interval: 6);

          date = '${DateFormat('MMMM ''yyyy', 'id').format(lastDate.from)}  -  ${DateFormat('MMMM ''yyyy', 'id').format(lastDate.to)}';
          deliveryOrder = DeliveryOrder.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        default:
          LastDateFrom lastDate = LastDateFrom.months(interval: 0);
          date = DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(lastDate.to);
        return _reportDelivery = defineError();
      }

      return await deliveryOrder.then((value) {

        return defineValueTonase(value: value);
      }).onError((error, stackTrace) => defineError());
    } else {
      date = DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime.now());
      return _reportDelivery = defineError();
    }
  }

  DeliveryOrder defineValueTonase({required Map value}) {
    total[0] = double.parse(value['realisasi']);
    total[1] = double.parse(value['outstanding']);
    total[2] = 500.0;

    percent[0] = (double.parse(value['realisasi']) / total[2] * 100).toStringAsFixed(2);
    percent[1] = (double.parse(value['outstanding']) / total[2] * 100).toStringAsFixed(2);
    setState(() => isOffline = false);
    return DeliveryOrder(
      tonage: total[0],
      outstanding_tonage: total[1],
      target: total[2]
    );
  }

  Future<DeliveryOrder> defineError() async {
    setState(() => isOffline = true);
    return const DeliveryOrder(tonage: 99.9, outstanding_tonage: 99.9, target: 99.9);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      width: null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: DisableWidget(
          disable: isOffline,
          overlay: (context) {
            return AnimatedSwitcher(
              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 400),
              child: isOffline ? Stack(
                children: [
                  const HandleNoData(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: DropdownCustomerSelect(onChanged: () {
                        setReportDelivery();
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Perolehan Kamu', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  letterSpacing: 0
                                )),
                              ],
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: dateRange,
                                onChanged: (value) => setState(() {
                                  dateRange = value.toString();
                                  setReportDelivery();
                                }),
                                padding: const EdgeInsets.only(left: 6),
                                isDense: true,
                                elevation: 0,
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
                        Text(date,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 10,
                            letterSpacing: 0,
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ) : null,
            );
          },
          child: FutureBuilder(
            future: _reportDelivery,
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                switchInCurve: Curves.fastOutSlowIn,
                switchOutCurve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 800),
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
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
                        Theme.of(context).colorScheme.primaryContainer
                      ]
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
                              ],
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: dateRange,
                                onChanged: (value) => setState(() {
                                  dateRange = value.toString();
                                  setReportDelivery();
                                }),
                                padding: const EdgeInsets.only(left: 6),
                                isDense: true,
                                elevation: 0,
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
                                        padding: const EdgeInsets.only(top: 30),
                                        child: DeliveryChartWidget(
                                          DeliveryOrder(
                                            tonage: total[0],
                                            outstanding_tonage: total[1],
                                            target: total[2]
                                          )
                                        )
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(date,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontSize: 10,
                                          letterSpacing: 0,
                                        )
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            ChipSmall(
                                              bgColor: DeliveryOrder.description(context: context)[0]['color'],
                                              label: '${percent[0]} %',
                                              labelColor: Theme.of(context).colorScheme.surface
                                            ),
                                            ChipSmall(
                                              bgColor: DeliveryOrder.description(context: context)[1]['color'],
                                              label: '${percent[1]} %',
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
                                          Icon(Icons.bar_chart, size: 16, color: DeliveryOrder.description(context: context)[i]['color'])
                                        ],
                                      ),
                                    ],
                                  )
                                ]
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        MediaQuery.removePadding(
                          context: context,
                          removeLeft: true,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownCustomerSelect(onChanged: () {
                                setReportDelivery();
                              }),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButtonOpen(
                                  label: 'Rincian Pencapaian',
                                  onPressed: () {
                                    pushDetailReport(context: context, onPop: () {
                                      setState(() { });
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}