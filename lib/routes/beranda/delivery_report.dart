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
  bool isOffline = false, showOutstanding = true;

  late List<String> datesRange;
  late String dateRange;
  late String date;
  late Future<DeliveryOrder> _reportDelivery;

  late DeliveryOrder deliveryOrder;
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
          showOutstanding = false;
          deliveryOrder = DeliveryOrder.retrieveWeek(id_ocst: id_ocst, date: DateTime.now());
        break;

        case 'BULAN INI':
          LastDateFrom lastDate = LastDateFrom.months(interval: 0);

          date = DateFormat('MMMM ''yyyy', 'id').format(lastDate.to);
          showOutstanding = true;
          deliveryOrder = DeliveryOrder.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        case '3 BULAN':
          LastDateFrom lastDate = LastDateFrom.months(interval: 3);

          date = '${DateFormat('MMMM ''yyyy', 'id').format(lastDate.from)}  -  ${DateFormat('MMMM ''yyyy', 'id').format(lastDate.to)}';
          showOutstanding = false;
          deliveryOrder = DeliveryOrder.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        case '6 BULAN':
          LastDateFrom lastDate = LastDateFrom.months(interval: 6);

          date = '${DateFormat('MMMM ''yyyy', 'id').format(lastDate.from)}  -  ${DateFormat('MMMM ''yyyy', 'id').format(lastDate.to)}';
          showOutstanding = false;
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
    deliveryOrder = DeliveryOrder.toObject(value);

    // FIXME: DeliveryOrder Percentage not Using Class Object
    percent[0] = (double.parse(value['realisasi']) / deliveryOrder.target * 100).toStringAsFixed(2);
    percent[1] = (double.parse(value['outstanding']) / deliveryOrder.target * 100).toStringAsFixed(2);
    setState(() => isOffline = false);
    return deliveryOrder;
  }

  Future<DeliveryOrder> defineError() async {
    setState(() => isOffline = true);
    return DeliveryOrder(tonage: Tonage(weight: 99.9), outstanding_tonage: Outstanding(weight: 99.9), target: 99.9);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
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
                                        padding: const EdgeInsets.only(top: 20),
                                        child: DeliveryChartWidget(
                                          showOutstanding: showOutstanding,
                                          deliveryOrder: deliveryOrder
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
                                              bgColor: Theme.of(context).colorScheme.primary,
                                              label: '${percent[0]} %',
                                              labelColor: Theme.of(context).colorScheme.surface
                                            ),
                                            Visibility(
                                              visible: showOutstanding,
                                              child: ChipSmall(
                                                bgColor: Theme.of(context).colorScheme.inversePrimary,
                                                label: '${percent[1]} %',
                                                labelColor: Theme.of(context).colorScheme.inverseSurface
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
                                  ListDeliveryOrder(
                                    deliveryOrder: deliveryOrder,
                                    color: Theme.of(context).colorScheme.primary,
                                    name: deliveryOrder.tonage.name,
                                    weight: deliveryOrder.tonage.weight,
                                  ),
                                  ListDeliveryOrder(
                                    deliveryOrder: deliveryOrder,
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    name: deliveryOrder.outstanding_tonage.name,
                                    weight: deliveryOrder.outstanding_tonage.weight,
                                    visible: showOutstanding
                                  ),
                                  ListDeliveryOrder(
                                    deliveryOrder: deliveryOrder,
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                    name: 'Target',
                                    weight: deliveryOrder.target,
                                  ),
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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

class ListDeliveryOrder extends StatelessWidget {
  const ListDeliveryOrder({super.key, required this.deliveryOrder, required this.color, required this.name, required this.weight, this.visible});

  final DeliveryOrder deliveryOrder;
  final Color color;
  final String name;
  final double weight;
  final bool? visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: visible == false ? 0 : null,
        child: Column(
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
                          color: color,
                          borderRadius: BorderRadius.circular(4)
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(name, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0
                      )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('$weight Ton', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0
                  )),
                ),
                Icon(Icons.bar_chart, size: 16, color: color)
              ],
            ),
          ],
        ),
      ),
    );
  }
}