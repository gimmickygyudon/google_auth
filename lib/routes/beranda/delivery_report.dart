// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/chip.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:intl/intl.dart';

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
  late String date;
  late Future<DeliveryOrder> _reportDelivery;

  List<double> total = List.generate(3, (index) => 0.0);
  List<String> percent = List.generate(2, (index) => '0.0');

  @override
  void initState() {
    datesRange = ['Minggu Ini', 'Bulan Ini', '3 Bulan', '6 Bulan', 'Total'];
    dateRange = datesRange[1];

    _reportDelivery = setReportDelivery();
    super.initState();
  }

  Future<DeliveryOrder> setReportDelivery() async {
    // TODO: id_ocst PINNED or SET AS DEFAULT
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);

    if (id_ocst != null) {
      switch (dateRange.toUpperCase()) {
        case 'MINGGU INI':
          DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime(DateTime.now().year, 05));
          date = '${getCurrentStartEndWeek(DateTime(DateTime.now().year, 05), format: 'dd MMMM').keys.first}  -  ${getCurrentStartEndWeek(DateTime(DateTime.now().year, 05), format: 'dd MMMM').values.first}';
          return _reportDelivery = DeliveryOrder.retrieveWeek(id_ocst: id_ocst, date: DateTime(DateTime.now().year, 05)).then((value) {
            return defineValueTonase(value: value);
          }).onError((error, stackTrace) => defineError());

        case 'BULAN INI':
          date = DateFormat('MMMM ''yyyy', 'id').format(DateTime(DateTime.now().year, 05));
          return _reportDelivery = DeliveryOrder.retrieveMonth(
            id_ocst: id_ocst,
            date: DateTime(DateTime.now().year, 05))
          .then((value) {
              return defineValueTonase(value: value);
            }).onError((error, stackTrace) => defineError());

        case '3 BULAN':
          date = '${DateFormat('MMMM ''yyyy', 'id').format(DateTime(DateTime.now().year, 05 - 02, 01))}  -  ${DateFormat('MMMM ''yyyy', 'id').format(DateTime(DateTime.now().year, 05, DateTime.now().lastDayOfMonth))}';
          return _reportDelivery = DeliveryOrder.retrieveLastMonths(
            id_ocst: id_ocst,
            from: DateTime(DateTime.now().year, 05 - 02, 01),
            to: DateTime(DateTime.now().year, 05, DateTime.now().lastDayOfMonth))
          .then((value) {
            return defineValueTonase(value: value);
          }).onError((error, stackTrace) => defineError());

        case '6 BULAN':
          date = '${DateFormat('MMMM ''yyyy', 'id').format(DateTime(DateTime.now().year, 05 - 06, 01))}  -  ${DateFormat('MMMM ''yyyy', 'id').format(DateTime(DateTime.now().year, 05, DateTime.now().lastDayOfMonth))}';
          return _reportDelivery = DeliveryOrder.retrieveLastMonths(
            id_ocst: id_ocst,
            from: DateTime(DateTime.now().year, 05 - 06, 01),
            to: DateTime(DateTime.now().year, 05, DateTime.now().lastDayOfMonth))
          .then((value) {
            return defineValueTonase(value: value);
          }).onError((error, stackTrace) => defineError());

        default:
          date = DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime(DateTime.now().year, 05));
          return _reportDelivery = defineError();
      }
    } else {
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
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => isOffline = true);
    });
    return const DeliveryOrder(tonage: 99.9, outstanding_tonage: 99.9, target: 99.9);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  border: isOffline ? Border(top: BorderSide(width: 2, color: Theme.of(context).colorScheme.error)) : Border.all(width: 0, color: Colors.transparent)
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
                              const SizedBox(width: 10),
                              if (isOffline) const ChipOffline()
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
                      const SizedBox(height: 10),
                      MediaQuery.removePadding(
                        context: context,
                        removeLeft: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomerSelectWidget(onChanged: () {
                              setState(() {
                                _reportDelivery = setReportDelivery();
                              });
                            }),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: ButtonStyle(
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 6)),
                                  textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.25)),
                                  iconSize: const MaterialStatePropertyAll(16)
                                ),
                                onPressed: () => pushDetailReport(context: context, onPop: () {
                                  setState(() {
                                    _reportDelivery = setReportDelivery();
                                  });
                                }),
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

class CustomerSelectWidget extends StatefulWidget {
  const CustomerSelectWidget({super.key, required this.onChanged});

  final Function onChanged;

  @override
  State<CustomerSelectWidget> createState() => _CustomerSelectWidgetState();
}

class _CustomerSelectWidgetState extends State<CustomerSelectWidget> {
  late Future<List<Customer>> _getCustomer;

  @override
  void initState() {
    _getCustomer = Customer.retrieve(id_ousr: currentUser['id_ousr']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCustomer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.7),
              border: Border.all(color: Theme.of(context).colorScheme.primary)
            ),
            child: ValueListenableBuilder(
              valueListenable: Customer.defaultCustomer,
              builder: (context, customer, child) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<Customer?>(
                    value: customer,
                    onChanged: (Customer? value) {
                      setState(() {
                        Customer.setDefaultCustomer(value);
                        widget.onChanged();
                      });
                    },
                    isDense: true,
                    padding: const EdgeInsets.all(4),
                    borderRadius: BorderRadius.circular(8),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary
                    ),
                    iconEnabledColor: Theme.of(context).colorScheme.primary,
                    items: snapshot.data?.map<DropdownMenuItem<Customer>>((Customer customer) {
                      return DropdownMenuItem<Customer>(
                        value: customer,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4),
                            Icon(Icons.account_circle, size: 18, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(customer.remarks),
                          ],
                        )
                      );
                    }).toList(),
                  ),
                );
              }
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}