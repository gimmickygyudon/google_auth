// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/routes/beranda/delivery_report.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/chart.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/profile.dart';

import '../../functions/color.dart';
import '../../widgets/text.dart';

class DetailReportRoute extends StatefulWidget {
  const DetailReportRoute({super.key});

  @override
  State<DetailReportRoute> createState() => _DetailReportRouteState();
}

class _DetailReportRouteState extends State<DetailReportRoute> {
  late List<String> months;
  late String? selectedMonth;
  late List<String> years;
  late String? selectedYears;

  late double realisasi, outstanding, total;
  ValueNotifier<List<int>> count = ValueNotifier([0, 0]);
  late Future<DeliveryOrder> _deliveryOrder;

  @override
  void initState() {
    setRange();
    _deliveryOrder = setDeliveryOrder();
    super.initState();
  }

  Future<DeliveryOrder> setDeliveryOrder() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);

    int month = months.indexOf(selectedMonth!);
    return _deliveryOrder = DeliveryOrder.retrieveMonth(id_ocst: id_ocst!, date: DateTime(int.parse(selectedYears!), month + 1)).then((value) {
      return defineValueTonase(value: value);
    });
  }

  DeliveryOrder defineValueTonase({required Map value}) {
    realisasi = double.parse(value['realisasi']);
    outstanding = double.parse(value['outstanding']);
    count.value = [value['realisasi_count'], value['outstanding_count']];
    total = 500.0;

    return DeliveryOrder(
      tonage: realisasi,
      outstanding_tonage: outstanding,
      target: total
    );
  }

  setRange() {
    months = generateListofMonths(DateTime.now());
    selectedMonth = months[DateTime.now().month - 1];

    years = generateListoYears(DateTime.now());
    selectedYears = years.last;
  }

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
            child: CustomerSelectWidget(onChanged: () {
              setState(() {
                _deliveryOrder = setDeliveryOrder();
              });
            }),
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
              const TextIcon(
                label: 'Analisa Pencapaian',
                icon: Icons.show_chart
              ),
              Text('Rincian detail delivery order anda selama ini.', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0
              )),
              Divider(height: 60, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ringkasan', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 0
                      )),
                      const SizedBox(height: 4),
                      ValueListenableBuilder(
                        valueListenable: count,
                        builder: (context, count, child) {
                          return Row(
                            children: List.generate(count.length, (index) {
                              return Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: DeliveryOrder.description(context: context)[index]['color'],
                                      borderRadius: BorderRadius.circular(2)
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    count[index].toString(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 9,
                                    height: 0,
                                    letterSpacing: 0
                                  )),
                                  const SizedBox(width: 8),
                                ],
                              );
                            }).toList(),
                          );
                        }
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 2, 4, 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: DropdownButton(
                          isDense: true,
                          underline: const SizedBox(),
                          value: selectedMonth,
                          borderRadius: BorderRadius.circular(8),
                          onChanged: (month) {
                            setState(() {
                              _deliveryOrder = setDeliveryOrder();
                              selectedMonth = month;
                            });
                          },
                          elevation: 0,
                          dropdownColor: lighten(Theme.of(context).colorScheme.primaryContainer, 0.05),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0
                          ),
                          iconEnabledColor: Theme.of(context).colorScheme.primary,
                          items: months.map((month) {
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month)
                            );
                          }).toList()
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 2, 4, 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: DropdownButton(
                          isDense: true,
                          underline: const SizedBox(),
                          value: selectedYears,
                          borderRadius: BorderRadius.circular(8),
                          onChanged: (year) {
                            setState(() {
                              _deliveryOrder = setDeliveryOrder();
                              selectedYears = year;
                            });
                          },
                          elevation: 0,
                          dropdownColor: lighten(Theme.of(context).colorScheme.primaryContainer, 0.05),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0
                          ),
                          iconEnabledColor: Theme.of(context).colorScheme.primary,
                          items: years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year)
                            );
                          }).toList()
                        ),
                      ),
                    ],
                  )
                ],
              ),
              FutureBuilder(
                future: _deliveryOrder,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const HandleLoading();
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return POBarChart(
                      sectors: DeliveryOrder(
                        tonage: realisasi,
                        outstanding_tonage: outstanding,
                        target: total
                      ),

                      titlebottom: DeliveryOrder.description(context: context).map((element) => element['name']).toList(),
                      colors: DeliveryOrder.description(context: context).map<Color>((element) => element['color']).toList(),
                      borderRadius: BorderRadius.circular(2),

                      dark: DeliveryOrder.description(context: context)[0]['color'],
                      normal: DeliveryOrder.description(context: context)[1]['color'],
                      light: DeliveryOrder.description(context: context)[2]['color']
                    );
                  } else {
                    return const HandleNoInternet(message: 'Gagal Tersambung ke Server',);
                  }
                }
              )
            ],
          ),
        )
      ),
    );
  }
}